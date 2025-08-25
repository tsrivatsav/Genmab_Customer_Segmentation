# Start with the official AWS Deep Learning Container for PyTorch
FROM 763104351884.dkr.ecr.us-east-1.amazonaws.com/pytorch-inference:1.13.1-cpu-py39-ubuntu20.04-sagemaker

# Install the transformers library
RUN pip install transformers sentencepiece

# Copy your fine-tuned model and Lambda handler code
COPY --chown=model-server:model-server fine-tuned-model/ /opt/ml/model/
COPY --chown=model-server:model-server lambda_function.py /home/model-server/

# Set the command to run when the container starts
CMD ["lambda_function.lambda_handler"]