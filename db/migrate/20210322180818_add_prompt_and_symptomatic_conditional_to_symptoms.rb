class AddPromptAndSymptomaticConditionalToSymptoms < ActiveRecord::Migration[6.1]
  def change
    add_column :symptoms, :prompt, :string, default: ''
    add_column :symptoms, :symptomatic_conditional, :bool, default: false
  end
end
