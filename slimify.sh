#!/bin/bash

set -e

PIP_DOWNLOAD_CMD="pip download --no-deps --disable-pip-version-check"

mkdir -p dist

(
    cd dist

    if [[ -z "${NUMPY_VERSION}" ]]; then
        echo "Set the NUMPY_VERSION environment variable."
        exit 1
    fi

    echo "slimming wheels for numpy version ${NUMPY_VERSION}"

    if [ $TARGETPLATFORM == "linux/amd64" ]; then 
        $PIP_DOWNLOAD_CMD --python-version 3.10 --platform manylinux2014_x86_64 numpy==${NUMPY_VERSION}
        $PIP_DOWNLOAD_CMD --python-version 3.9 --platform manylinux2014_x86_64 numpy==${NUMPY_VERSION}
        $PIP_DOWNLOAD_CMD --python-version 3.8 --platform manylinux2014_x86_64 numpy==${NUMPY_VERSION}
        $PIP_DOWNLOAD_CMD --python-version 3.7 --platform manylinux2014_x86_64 numpy==${NUMPY_VERSION}
        $PIP_DOWNLOAD_CMD --python-version 3.9 --platform manylinux2010_x86_64 numpy==${NUMPY_VERSION}
        $PIP_DOWNLOAD_CMD --python-version 3.8 --platform manylinux2010_x86_64 numpy==${NUMPY_VERSION}
        $PIP_DOWNLOAD_CMD --python-version 3.7 --platform manylinux2010_x86_64 numpy==${NUMPY_VERSION}
        $PIP_DOWNLOAD_CMD --python-version 3.8 --platform manylinux1_x86_64 numpy==${NUMPY_VERSION}
        $PIP_DOWNLOAD_CMD --python-version 3.7 --platform manylinux1_x86_64 numpy==${NUMPY_VERSION}
    elif [ $TARGETPLATFORM == "linux/aarch64" ]; then
        $PIP_DOWNLOAD_CMD --python-version 3.10 --platform manylinux2014_aarch64 numpy==${NUMPY_VERSION}
        $PIP_DOWNLOAD_CMD --python-version 3.9 --platform manylinux2014_aarch64 numpy==${NUMPY_VERSION}
        $PIP_DOWNLOAD_CMD --python-version 3.8 --platform manylinux2014_aarch64 numpy==${NUMPY_VERSION}
        $PIP_DOWNLOAD_CMD --python-version 3.7 --platform manylinux2014_aarch64 numpy==${NUMPY_VERSION}
    else
        echo "${TARGETPLATFORM} not currently supported."
    fi

    for filename in ./*.whl
    do
        zip -d ${filename} \
            \*tests/\* \
            \*testing/\* \
            \*_examples/\*

        wheel unpack $filename
        find numpy-${NUMPY_VERSION}/ -name "*.so" | xargs strip
        #find numpy-${NUMPY_VERSION}/ -name "*.so.*" | xargs strip
        find numpy-${NUMPY_VERSION}/ -name "*.a" | xargs strip
        rm $filename
        wheel pack numpy-${NUMPY_VERSION}

        rm -r numpy-${NUMPY_VERSION}
    done

    pip uninstall -y --disable-pip-version-check numpy

    if [ $TARGETPLATFORM == "linux/amd64" ]; then
        pip install --no-cache-dir --disable-pip-version-check "numpy-${NUMPY_VERSION}-cp310-cp310-manylinux2014_x86_64.manylinux_2_17_x86_64.whl"
    elif [ $TARGETPLATFORM == "linux/aarch64" ]; then
        pip install --no-cache-dir --disable-pip-version-check "numpy-${NUMPY_VERSION}-cp310-cp310-manylinux2014_aarch64.manylinux_2_17_aarch64.whl"
    else
        echo "${TARGETPLATFORM} not currently supported."
    fi
)

python test.py
