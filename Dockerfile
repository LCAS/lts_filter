FROM nvidia/cudagl:11.4.1-base-ubuntu20.04

# Config
ENV ROS_DISTRO noetic

# Minimal setup
RUN apt-get update && apt-get install -y locales lsb-release
ARG DEBIAN_FRONTEND=noninteractive
RUN dpkg-reconfigure locales

# Setup torch, cuda for the model and other dependencies 
RUN apt install -y python3-pip git &&\  
    pip install torch==1.7.1+cu110 \
    torchvision==0.8.2+cu110 \
    torchaudio===0.7.2 -f https://download.pytorch.org/whl/cu110/torch_stable.html 

# Install ROS
# a. Setup your sources.list
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'

# b. Set up the keys
RUN apt install -y curl wget && \
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

# c. Installation
RUN apt update && \
    apt install -y ros-${ROS_DISTRO}-ros-base && \
    echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc

# Install catkin tools and other packages 
RUN apt update && \
    apt install -y ros-noetic-ros-numpy && \
    pip install catkin_tools 

# Clone the filter and Download the model
RUN cd  /home && \
    mkdir -p c_ws/src && \
    cd c_ws/src && \
    git clone https://github.com/ibrahimhroob/inference_model.git && \
    cd inference_model/lts_filter/model && \
    wget https://lcas.lincoln.ac.uk/nextcloud/index.php/s/KTS4XYWxGxbYtXs/download -O best_model.pth

    
RUN apt-get update && \
    apt-get install -y ros-${ROS_DISTRO}-catkin && \
    cd /home/c_ws && \
    catkin_make && \
    source devel/setup.bash

WORKDIR /home

