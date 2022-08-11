class Tree::Instance::Sync
  include Callable

  def initialize(tree_instance:)
    @tree_instance = tree_instance
  end

  def call
    Tree::Instance::Sync::MissingNodes::Create.call(tree_instance: tree_instance)
  end

  private

  attr_reader :tree_instance
end
