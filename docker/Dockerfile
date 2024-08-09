ARG base_image=ghcr.io/cyclus/cymetric_22.04_conda/cymetric:latest
ARG site_type=no-api

FROM ${base_image} AS site-no-api
COPY . /cyclus.github.com
WORKDIR /cyclus.github.com
RUN mamba install -y sphinx sphinxcontrib-bibtex cloud_sptheme

RUN make gh-preview

FROM ${base_image} AS site-api

# update packages and install doxygen
RUN mamba update --all -y && mamba install -y doxygen

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
COPY --from=site-no-api /cyclus.github.com/${BUILDDIR} /cyclus.github.com/
WORKDIR /cyclus.github.com

# copy the docs to the site html folder
RUN rsync -a /cyclus/build/doc/html/* /cyclus.github.com/${BUILDDIR}/cyclus/api/ && \
    rsync -a /cyclus/build/doc/html/* /cyclus.github.com/${BUILDDIR}/cycamore/api/


FROM site-${site_type}
COPY --from=site /cyclus.github.com/${BUILD_DIR} /${BUILD_DIR}

