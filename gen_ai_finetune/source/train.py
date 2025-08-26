import argparse
import os
import pandas as pd
from sklearn.model_selection import train_test_split
from transformers import DistilBertTokenizer, DistilBertForSequenceClassification, Trainer, TrainingArguments
import torch

class ReviewDataset(torch.utils.data.Dataset):
    def __init__(self, encodings, labels):
        self.encodings = encodings
        self.labels = labels

    def __getitem__(self, idx):
        item = {key: torch.tensor(val[idx]) for key, val in self.encodings.items()}
        item['labels'] = torch.tensor(self.labels[idx])
        return item

    def __len__(self):
        return len(self.labels)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    # SageMaker passes hyperparams and data paths as command-line arguments.
    parser.add_argument('--model_dir', type=str, default=os.environ.get('SM_MODEL_DIR'))
    parser.add_argument('--train', type=str, default=os.environ.get('SM_CHANNEL_TRAIN'))
    
    args, _ = parser.parse_known_args()

    # 1. Load and preprocess data
    df = pd.read_csv(os.path.join(args.train, 'Reviews.csv'))
    df = df.head(200)
    df = df[['Text', 'Score']].dropna()
    df['label'] = df['Score'].apply(lambda x: 1 if x > 3 else 0) # Simple binary sentiment
    
    train_texts, val_texts, train_labels, val_labels = train_test_split(
        df['Text'].tolist(), df['label'].tolist(), test_size=0.1
    )

    # 2. Tokenize data
    model_name = 'distilbert-base-uncased'
    tokenizer = DistilBertTokenizer.from_pretrained(model_name)
    
    train_encodings = tokenizer(train_texts, truncation=True, padding=True, max_length=128)
    val_encodings = tokenizer(val_texts, truncation=True, padding=True, max_length=128)

    train_dataset = ReviewDataset(train_encodings, train_labels)
    val_dataset = ReviewDataset(val_encodings, val_labels)

    # 3. Load model
    model = DistilBertForSequenceClassification.from_pretrained(model_name, num_labels=2)
    
    # 4. Set up Trainer
    training_args = TrainingArguments(
        output_dir='./results',
        num_train_epochs=1,
        per_device_train_batch_size=16,
        per_device_eval_batch_size=16,
        logging_dir='./logs',
        logging_steps=100,
    )

    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=train_dataset,
        eval_dataset=val_dataset
    )

    # 5. Start training
    trainer.train()
    
    # 6. Save the fine-tuned model to the path SageMaker expects
    trainer.save_model(args.model_dir)
    tokenizer.save_pretrained(args.model_dir)