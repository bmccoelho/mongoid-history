module Mongoid::History
  module Tracker
    extend ActiveSupport::Concern

    included do
      include Mongoid::Document
      include Mongoid::Timestamps
      attr_writer :trackable

      field :association_chain, :type => Mongoid::History::Association::Field
      field :modified,          :type => Hash
      field :original,          :type => Hash
      field :version,           :type => Integer
      field :action,            :type => String
      field :scope,             :type => String

      referenced_in :modifier, :class_name => Mongoid::History.modifier_class_name

      Mongoid::History.tracker_class = self
      Sweeper.hook!
    end

    def undo!(modifier)
      Operation::Undo.new(trackable).execute!(modifier, version)
    end

    def redo!(modifier)
      Operation::Redo.new(trackable).execute!(modifier, version)
    end

    def trackable
      association_chain.leaf.doc
    end
  end
end
