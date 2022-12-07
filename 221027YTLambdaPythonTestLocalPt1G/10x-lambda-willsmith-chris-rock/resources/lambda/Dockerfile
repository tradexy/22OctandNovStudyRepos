FROM public.ecr.aws/lambda/python:3.8
COPY requirements.txt ${LAMBDA_TASK_ROOT}
RUN pip3 install --no-cache-dir -r requirements.txt
COPY hello-world.py ${LAMBDA_TASK_ROOT}

CMD ["hello-world.lambda_handler"]