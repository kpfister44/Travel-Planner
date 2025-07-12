import logging
import sys
from logging.config import dictConfig


def setup_logging():
    logging_config = {
        "version": 1,
        "disable_existing_loggers": False,  # keep existing loggers (like uvicorn)
        "formatters": {
            "default": {
                "format": "[%(asctime)s] [%(process)d] [%(levelname)s] [%(name)s] %(message)s",
            },
        },
        "handlers": {
            "default": {
                "level": "INFO",
                "class": "logging.StreamHandler",
                "formatter": "default",
                "stream": sys.stdout,
            },
        },
        "loggers": {
            "uvicorn": {"handlers": ["default"], "level": "INFO", "propagate": False},
            "uvicorn.error": {
                "handlers": ["default"],
                "level": "INFO",
                "propagate": False,
            },
            "uvicorn.access": {
                "handlers": ["default"],
                "level": "INFO",
                "propagate": False,
            },
            "app": {
                "handlers": ["default"],
                "level": "DEBUG",
                "propagate": True,  # propagate to root logger
            },
            "app": {
                "handlers": ["default"],
                "level": "INFO",
                "propagate": True,  # propagate to root logger
            },
        },
        "root": {"level": "INFO", "handlers": ["default"]},
    }

    dictConfig(logging_config)
