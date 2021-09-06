# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_09_05_204014) do

  create_table "auth_tokens", force: :cascade do |t|
    t.string "client_id"
    t.string "client_secret"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "notification_channels", force: :cascade do |t|
    t.text "configs"
    t.string "name"
    t.integer "project_id", null: false
    t.string "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "project_id"], name: "index_notification_channels_on_name_and_project_id", unique: true
    t.index ["project_id"], name: "index_notification_channels_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "user_id"
    t.index ["name", "user_id"], name: "index_projects_on_name_and_user_id", unique: true
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "resources", force: :cascade do |t|
    t.string "type"
    t.integer "reference_id"
    t.text "params"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "sub_type"
    t.integer "parent_resource_id"
    t.index ["parent_resource_id"], name: "index_resources_on_parent_resource_id"
  end

  create_table "schedulers", force: :cascade do |t|
    t.string "type"
    t.string "schedule"
    t.integer "project_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.string "grafana_dashboard_id"
    t.text "notification_channels"
    t.integer "updated_by_user_id"
    t.string "pause_state"
    t.index ["project_id"], name: "index_schedulers_on_project_id"
    t.index ["updated_by_user_id"], name: "index_schedulers_on_updated_by_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "uid"
    t.string "grafana_password"
    t.string "grafana_user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

  add_foreign_key "notification_channels", "projects"
  add_foreign_key "projects", "users"
  add_foreign_key "resources", "resources", column: "parent_resource_id"
  add_foreign_key "schedulers", "projects"
  add_foreign_key "schedulers", "users", column: "updated_by_user_id"
end
