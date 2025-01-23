# Use Alpine as the base image
FROM alpine:latest

# Install necessary packages
RUN apk add --no-cache \
    bash \
    build-base \
    git \
    python3 \
    py3-pip \
    libgcc \
    gdb \
    clang19-dev \
    llvm19-dev \
    cmake \
    neovim \
    emacs \
    nano \
    doxygen \
    graphviz \
    ccache \
    cppcheck \
    pipx \
    ninja \
    ninja-build \
    wayland-dev \
    libxcb-dev \
    libxkbcommon-dev \
    libxkbcommon-x11 \
    libxrandr-dev \
    libxcursor-dev \
    libxi-dev \
    glfw-dev

RUN    pipx install conan
# Set environment variables for Conan
ENV CONAN_SYSREQUIRES_SUDO=0
ENV CONAN_SYSREQUIRES_MODE=enabled

# Set compiler defaults based on user arguments
ARG USE_CLANG
ENV CC=${USE_CLANG:+"clang"}
ENV CXX=${USE_CLANG:+"clang++"}
ENV CC=${CC:-"gcc"}
ENV CXX=${CXX:-"g++"}

# Install include-what-you-use
#ENV IWYU /home/iwyu
#ENV IWYU_BUILD ${IWYU}/build
#ENV IWYU_SRC ${IWYU}/include-what-you-use

#RUN mkdir -p ${IWYU_BUILD} && \
#    git clone --branch clang_${LLVM_VER} \
#        https://github.com/include-what-you-use/include-what-you-use.git \
#        ${IWYU_SRC} && \
#    cd ${IWYU_BUILD} && \
#    cmake -S ${IWYU_SRC} -B . -G "Unix Makefiles" -DCMAKE_PREFIX_PATH=/usr/lib/llvm-${LLVM_VER} && \
#    cmake --build . -j && \
#    cmake --install .

# Final cleanup (not much to clean in Alpine)
CMD ["/bin/bash"]