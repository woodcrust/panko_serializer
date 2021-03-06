# frozen_string_literal: true

module Panko
  class ArraySerializer
    attr_accessor :subjects

    def initialize(subjects, options = {})
      @subjects = subjects
      @each_serializer = options[:each_serializer]

      if @each_serializer.nil?
        raise ArgumentError, %{
Please pass valid each_serializer to ArraySerializer, for example:
> Panko::ArraySerializer.new(posts, each_serializer: PostSerializer)
        }
      end

      serializer_options = {
        only: options.fetch(:only, []),
        except: options.fetch(:except, []),
        context: options[:context],
        scope: options[:scope],
        group: options[:group]
      }

      @serialization_context = SerializationContext.create(options)
      @descriptor = Panko::SerializationDescriptor.build(@each_serializer, serializer_options, @serialization_context)
    end

    def to_json
      serialize_to_json @subjects
    end

    def serialize(subjects)
      serialize_with_writer(subjects, Panko::ObjectWriter.new).output
    end

    def to_a
      serialize_with_writer(@subjects, Panko::ObjectWriter.new).output
    end

    def serialize_to_json(subjects)
      serialize_with_writer(subjects, Oj::StringWriter.new(mode: :rails)).to_s
    end

    private

    def serialize_with_writer(subjects, writer)
      Panko.serialize_objects(subjects.to_a, writer, @descriptor)
      writer
    end
  end
end
