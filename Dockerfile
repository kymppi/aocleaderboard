FROM rust:1-alpine3.18
# This is important, see https://github.com/rust-lang/docker-rust/issues/85
ENV RUSTFLAGS="-C target-feature=-crt-static"
RUN apk add --no-cache musl-dev pkgconfig openssl-dev

RUN cargo new --bin /aocleaderboard

WORKDIR /aocleaderboard

COPY Cargo.toml Cargo.lock rust-toolchain.toml ./

# cache dependencies
RUN cargo build --release && rm -rf .git src/ target/

COPY src/ src/
COPY LICENSE LICENSE

# do a release build
RUN cargo build --release
RUN strip target/release/aocleaderboard

# use a plain alpine image, the alpine version needs to match the builder
FROM alpine:3.18
RUN apk add --no-cache libgcc
COPY --from=0 /aocleaderboard/target/release/aocleaderboard .
COPY templates/ templates/
COPY LICENSE LICENSE
ENTRYPOINT ["/aocleaderboard"]