import pandas as pd
from datasets import Dataset
from transformers import T5Tokenizer, T5ForConditionalGeneration, Trainer, TrainingArguments

# --- 1. Load Data ---
# Make sure you have downloaded 'Reviews.csv' into your 'generative-ai-api' folder
df = pd.read_csv("Reviews.csv")

# --- 2. Clean and Prepare Data ---
# Drop rows with missing values
df.dropna(subset=["Text", "Summary"], inplace=True)

# Select a smaller sample for faster fine-tuning
# Let's use 5,000 samples for training and 500 for validation
df_sample = df.sample(n=5500, random_state=42)

# Add a prefix to the input text, as is standard for T5 models
# This helps the model understand the task.
df_sample["Text"] = "summarize: " + df_sample["Text"]

# Split into training and validation sets
train_df = df_sample.iloc[:5000]
validation_df = df_sample.iloc[5000:]

# Convert Pandas DataFrames to Hugging Face Dataset objects
train_dataset = Dataset.from_pandas(train_df)
validation_dataset = Dataset.from_pandas(validation_df)

print("Data prepared. Training samples:", len(train_dataset))
print("Validation samples:", len(validation_dataset))

# --- 3. Tokenize Data ---
MODEL_NAME = "t5-small"

# Load the tokenizer associated with the T5 model
tokenizer = T5Tokenizer.from_pretrained(MODEL_NAME)

def preprocess_function(examples):
    """Tokenizes the input text and summary text."""
    # Tokenize the input text (the 'Text' column)
    model_inputs = tokenizer(examples["Text"], max_length=512, truncation=True, padding="max_length")
    
    # Tokenize the target text (the 'Summary' column)
    with tokenizer.as_target_tokenizer():
        labels = tokenizer(examples["Summary"], max_length=128, truncation=True, padding="max_length")

    model_inputs["labels"] = labels["input_ids"]
    return model_inputs

# Apply the tokenization to our datasets
tokenized_train_dataset = train_dataset.map(preprocess_function, batched=True)
tokenized_validation_dataset = validation_dataset.map(preprocess_function, batched=True)

# --- 4. Fine-Tune the Model ---

# Load the pre-trained T5 model
model = T5ForConditionalGeneration.from_pretrained(MODEL_NAME)

# Define the training arguments
training_args = TrainingArguments(
    output_dir="./results",          # Directory to save the model
    num_train_epochs=3,              # Total number of training epochs
    per_device_train_batch_size=4,   # Batch size for training
    per_device_eval_batch_size=4,    # Batch size for evaluation
    warmup_steps=500,                # Number of warmup steps for learning rate scheduler
    weight_decay=0.01,               # Strength of weight decay
    logging_dir="./logs",            # Directory for storing logs
    logging_steps=10,
    eval_strategy="epoch",     # Evaluate at the end of each epoch
)

# Create the Trainer instance
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_train_dataset,
    eval_dataset=tokenized_validation_dataset,
)

# Start the fine-tuning process!
trainer.train()

# --- 5. Save the Fine-Tuned Model ---
# This will be the model you package for your Lambda function
trainer.save_model("./fine-tuned-model")
tokenizer.save_pretrained("./fine-tuned-model")

print("Fine-tuning complete. Model saved to './fine-tuned-model'")