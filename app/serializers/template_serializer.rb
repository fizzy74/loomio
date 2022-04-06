class TemplateSerializer < ApplicationSerializer
  attributes :id,
             :name,
             :description,
             :record_type,
             :record_id,
             :priority,
             :demo_handle


  has_one :author, serializer: AuthorSerializer, root: :users
  has_one :record, polymorphic: true, :key => :ignore_me
end
