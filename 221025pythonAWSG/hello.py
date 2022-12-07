import sys

print('Hello, World!\nThe sum of 2 and 3 is 5.')

sum = int(sys.argv[1]) + int(sys.argv[2])

print(f'The sum of {sys.argv[1]} and {sys.argv[2]} is {sum}.')