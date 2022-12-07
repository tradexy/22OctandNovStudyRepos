part 1 use 10x-lambda

follow tutorial
https://www.youtube.com/watch?v=e0j0TQj330Q&t=1s

to develop aws lambda functions in python and boto3 locally and 10x faster

Wondering how to develop aws lambda  functions with python and boto3  locally and faster ? This video will walk you through simple hello world example on how you can develop and test lambda functions in python by not even toggling between aws console and your local desktop machine.
The example demonstrates how an aws event triggers  lambda function and you can see all the events right in your code editor.

steps for part 1. may use similar for part 2 below.
# Creating a Sample Lambda function
start watching form about 15mins https://www.youtube.com/watch?v=e0j0TQj330Q&t=1s
0. Have docker open - also use gitshell for commands
1. Create a Hello World Lambda Application in Pyhton
2. Create a Dockerfile that will build our Lambda Application and execute it in local Docker environment.
3. Create a sample shell script that can be used to trigger the Lambda function right in your terminal.
4. Execute `sh ./docker-test.sh`
5. Open new terminal and execute: curl -XPOST "http://localhost:9000/2015-03-31/f

on part 2 using curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'


part 2 use 10x-lambda-willsmith-chris-rock
from https://www.youtube.com/watch?v=GonSyKcICbE


