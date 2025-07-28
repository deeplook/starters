"""
An example of how to consume structured logs from the library.

This script sets up a JSON logger to process the structured data passed
in the 'extra' dictionary of the log records.
"""

import logging
import sys

from python_json_logger import jsonlogger

from clibro.config import APP_NAME
from clibro.core import increment

# 1. Create a handler that will output to the console.
logHandler = logging.StreamHandler(sys.stdout)

# 2. Create a JSON formatter.
# The format string can include standard LogRecord attributes, plus any
# keys from the 'extra' dictionary passed by the library.
formatter = jsonlogger.JsonFormatter("%(asctime)s %(name)s %(levelname)s %(message)s %(input_value)s %(operation)s")

# 3. Set the formatter for the handler.
logHandler.setFormatter(formatter)

# 4. Get the library's logger and configure it.
# We get the logger specifically to avoid changing the root logger.
lib_logger = logging.getLogger(APP_NAME)
lib_logger.addHandler(logHandler)
lib_logger.setLevel(logging.INFO)
lib_logger.propagate = False  # Prevent messages from being passed to the root logger

# 5. Call the library function.
print("--- Calling increment(42) ---")
increment(42)

# Example of a log from another part of the application that won't be JSON formatted
logging.basicConfig(level=logging.INFO)
logging.info("This is a standard, non-JSON log message.")
