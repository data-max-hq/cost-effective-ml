FROM rayproject/ray:2.3.0-py38

COPY mnist-tf.py mmist-tf.py
COPY sample_code.py sample_code.py

RUN pip install numpy tensorflow

CMD ["bin/bash"]

#FROM rayproject/ray:2.3.0-py38-gpu
#
#RUN pip install numpy tensorflow
#
#CMD ["bin/bash"]