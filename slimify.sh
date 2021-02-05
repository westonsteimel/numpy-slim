#!/bin/bash

set -e

pip install -U pip==20.2.4

PIP_DOWNLOAD_CMD="pip download --no-deps --disable-pip-version-check"

mkdir -p dist

(
    cd dist

    if [[ -z "${NUMPY_VERSION}" ]]; then
        NUMPY_VERSION=$(pip search numpy | pcregrep -o1 -e "^numpy \((.*)\).*$")
    fi

    echo "slimming wheels for numpy version ${NUMPY_VERSION}"

    $PIP_DOWNLOAD_CMD --python-version 3.9 --platform manylinux2014_x86_64 numpy==${NUMPY_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.8 --platform manylinux2014_x86_64 numpy==${NUMPY_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.7 --platform manylinux2014_x86_64 numpy==${NUMPY_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.6 --platform manylinux2014_x86_64 numpy==${NUMPY_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.9 --platform manylinux2010_x86_64 numpy==${NUMPY_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.8 --platform manylinux2010_x86_64 numpy==${NUMPY_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.7 --platform manylinux2010_x86_64 numpy==${NUMPY_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.6 --platform manylinux2010_x86_64 numpy==${NUMPY_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.9 --platform manylinux1_x86_64 numpy==${NUMPY_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.8 --platform manylinux1_x86_64 numpy==${NUMPY_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.7 --platform manylinux1_x86_64 numpy==${NUMPY_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.6 --platform manylinux1_x86_64 numpy==${NUMPY_VERSION}

    for filename in ./*.whl
    do
        zip -d ${filename} \
            \*tests/\* \
            \*testing/\*

        wheel unpack $filename
        find numpy-${NUMPY_VERSION}/ -name "*.so" | xargs strip
        #find numpy-${NUMPY_VERSION}/ -name "*.so.*" | xargs strip
        find numpy-${NUMPY_VERSION}/ -name "*.a" | xargs strip
        wheel pack numpy-${NUMPY_VERSION}

        rm -r numpy-${NUMPY_VERSION}
    done

    pip uninstall -y --disable-pip-version-check numpy
    pip install --disable-pip-version-check numpy -f .

    python -c "
import importlib
import numpy as np

module = importlib.import_module('numpy')
print(module.__version__)
"
)
