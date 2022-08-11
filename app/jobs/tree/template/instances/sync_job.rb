class Tree::Template::Instances::SyncJob < ApplicationJob
  queue_as :synchronizations

  def perform(tree_template_id:)
    Tree::Template::Instances::Sync
      .call(tree_template: Tree::Template.find(tree_template_id))
  end
end
