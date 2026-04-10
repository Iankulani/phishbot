#!/usr/bin/env python3
# setup.py for PHISH-BOT v2.0.0
# Author: Ian Carter Kulani

from setuptools import setup, find_packages
import os

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

with open("requirements.txt", "r", encoding="utf-8") as fh:
    requirements = [line.strip() for line in fh if line.strip() and not line.startswith("#")]

setup(
    name="phishbot",
    version="2.0.0",
    author="Ian Carter Kulani",
    author_email="ian@phishbot.io",
    description="Ultimate Cybersecurity & Phishing Command Center with Multi-Platform Bot Integration",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/phishbot/phishbot",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Information Technology",
        "Intended Audience :: System Administrators",
        "Topic :: Security",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.7",
    install_requires=requirements,
    entry_points={
        "console_scripts": [
            "phishbot=phishbot:main",
        ],
    },
    include_package_data=True,
    zip_safe=False,
)