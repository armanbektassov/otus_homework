FROM ruby:2.7.8

WORKDIR /code
COPY . /code
RUN bundle install && bundle add rackup

EXPOSE 4567

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "4567"]