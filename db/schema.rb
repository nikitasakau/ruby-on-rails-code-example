# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_04_30_182534) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  ###

  create_table "organization_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "organization_id", null: false
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "confirmed_at", precision: 6
    t.bigint "inviter_id", null: false
    t.index ["inviter_id"], name: "index_organization_memberships_on_inviter_id"
    t.index ["organization_id"], name: "index_organization_memberships_on_organization_id"
    t.index ["user_id", "organization_id"], name: "index_organization_memberships_on_user_id_and_organization_id", unique: true
    t.index ["user_id"], name: "index_organization_memberships_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tree_instance_nodes", force: :cascade do |t|
    t.bigint "tree_template_node_id", null: false
    t.bigint "tree_instance_id", null: false
    t.datetime "completed_at", precision: 6
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "ancestry"
    t.datetime "unblocked_at", precision: 6
    t.index ["ancestry"], name: "index_tree_instance_nodes_on_ancestry"
    t.index ["tree_instance_id"], name: "index_tree_instance_nodes_on_tree_instance_id"
    t.index ["tree_template_node_id", "tree_instance_id"], name: "index_instance_nodes_on_template_node_id_and_instance_id", unique: true
    t.index ["tree_template_node_id"], name: "index_tree_instance_nodes_on_tree_template_node_id"
  end

  create_table "tree_instances", force: :cascade do |t|
    t.bigint "tree_template_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["tree_template_id", "user_id"], name: "index_tree_instances_on_tree_template_id_and_user_id", unique: true
    t.index ["tree_template_id"], name: "index_tree_instances_on_tree_template_id"
    t.index ["user_id"], name: "index_tree_instances_on_user_id"
  end

  create_table "tree_template_nodes", force: :cascade do |t|
    t.string "icon", null: false
    t.string "title", null: false
    t.text "description"
    t.string "ancestry"
    t.bigint "tree_template_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["ancestry"], name: "index_tree_template_nodes_on_ancestry"
    t.index ["tree_template_id"], name: "index_tree_template_nodes_on_tree_template_id"
  end

  create_table "tree_templates", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["owner_type", "owner_id"], name: "index_tree_templates_on_owner_type_and_owner_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  ###

  add_foreign_key "organization_memberships", "organizations"
  add_foreign_key "organization_memberships", "users"
  add_foreign_key "organization_memberships", "users", column: "inviter_id"
  add_foreign_key "tree_instance_nodes", "tree_instances"
  add_foreign_key "tree_instance_nodes", "tree_template_nodes"
  add_foreign_key "tree_instances", "tree_templates"
  add_foreign_key "tree_instances", "users"
  add_foreign_key "tree_template_nodes", "tree_templates"
end
