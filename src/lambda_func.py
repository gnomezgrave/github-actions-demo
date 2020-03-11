def my_function(x, y):
    return x * y


def handler(event, context):
    print("Hello world, this is my lambda. What do you think?")

    print("The output is", my_function(10, 20))
