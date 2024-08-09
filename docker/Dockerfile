ARG base_image=ghcr.io/cyclus/cymetric_22.04_conda/cymetric:latest

FROM ${base_image} AS site-no-api
COPY . /cyclus.github.com
WORKDIR /cyclus.github.com
RUN mamba install -y sphinx sphinxcontrib-bibtex cloud_sptheme

RUN make gh-preview

FROM ${base_image} AS site-api

# update packages and install doxygen
RUN mamba update --all -y && mamba install -y doxygen rsync

# clean rebuild cyclus
WORKDIR /cyclus
RUN python3 install.py --allow-milps -j 6 --clean-build
WORKDIR /cyclus/build
RUN make cyclusdoc

# clean rebuild cycamore
WORKDIR /cycamore
RUN python3 install.py --allow-milps -j 6 --clean-build
WORKDIR /cycamore/build
RUN make cycamoredoc

# copy the built site in
ARG BUILDDIR=./gh-build
COPY --from=site-no-api /cyclus.github.com/${BUILDDIR} /cyclus.github.com/${BUILDDIR}
WORKDIR /cyclus.github.com

# copy the docs to the site html folder
RUN mkdir -p /cyclus.github.com/${BUILDDIR}/cyclus/api && mkdir -p /cyclus.github.com/${BUILDDIR}/cycamore/api
RUN rsync -a /cyclus/build/doc/html/* /cyclus.github.com/${BUILDDIR}/cyclus/api/ && \
    rsync -a /cyclus/build/doc/html/* /cyclus.github.com/${BUILDDIR}/cycamore/api/
RUN ls -lR /cyclus.github.com

FROM site-${site_type}
ARG site_type=no-api
COPY --from=site-${site_type} /cyclus.github.com/${BUILD_DIR} /${BUILD_DIR}
RUN ls -lR /${BUILD_DIR}
