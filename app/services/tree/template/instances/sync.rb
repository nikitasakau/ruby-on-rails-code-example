class Tree::Template::Instances::Sync
  include Callable

  def initialize(tree_template:)
    @tree_template = tree_template
  end

  def call
    tree_template
      .instances
      .includes(:nodes, template: %i[nodes])
      .each { |tree_instance| Tree::Instance::Sync.call(tree_instance: tree_instance) }
  end

  private

  attr_reader :tree_template
end
