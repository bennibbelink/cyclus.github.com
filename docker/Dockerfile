FROM ghcr.io/cyclus/cymetric_22.04_conda/cymetric:latest AS site

RUN mamba install -y sphinx sphinxcontrib-bibtex cloud_sptheme

FROM site AS api-docs
COPY . /cyclus.github.com

RUN mamba update --all -y && mamba install -y doxygen

WORKDIR /cyclus
RUN python3 install.py --allow-milps -j 2 --clean-build
WORKDIR /cyclus/build
RUN make cyclusdoc

WORKDIR /cycamore
RUN python3 install.py --allow-milps -j 2 --clean-build
WORKDIR /cycamore/build
RUN make cycamoredoc

WORKDIR /cyclus.github.com
ARG BUILDDIR=./gh-build
RUN make gh-preview && chmod -R 777 ${BUILDDIR} && \
    rsync -a /cyclus/build/doc/html/* ${BUILDDIR}/cyclus/api/ && \
    rsync -a /cyclus/build/doc/html/* ${BUILDDIR}/cycamore/api/


FROM scratch
COPY --from=api-docs /cyclus.github.com/${BUILD_DIR} /${BUILD_DIR}
