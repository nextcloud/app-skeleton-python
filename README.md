# Nextcloud Python App Skeleton repository

To make it easier to create new Nextcloud applications using Python,
you can immediately either clone this repository or simply copy it and use it as the basis for your future application.

By default, linters, pre-commit and other useful little things are configured here.

### Note

When the main.py file is executed, it instantiates the `APP` class and everything outside of the `__main__` block is executed first.
Now when the `__main__` block is executed, the `run_app` function is called with the `"main:APP"` as one argument, which in turn executes the main.py file (`__main__` is not executed here) and starts the application in uvicorn: `run_app("main:APP", log_level="trace")` resulting in double execution of the code outside the `__main__` block.
The argument `"main:APP"` is the name of the module and the name of the application instance. `run_app` or `uvicorn.run` can also work with just `APP` but then the ability to run multiple workers is lost, which might not be desired in some cases like production environments where the app can make use of multiple CPU cores.
Real world example for both cases can be found in [Visionatrix](https://github.com/Visionatrix/Visionatrix/blob/9c9802468b79fb054599b3af68fd05bcc9105375/visionatrix/backend.py#L262-L278).

Any code to be executed in the main module should be placed in the `lifespan` function before the `yield` statement. It is called when the application is started by a uvicorn worker and is executed only once. Global variables can be set and exported here with the `global` keyword.
