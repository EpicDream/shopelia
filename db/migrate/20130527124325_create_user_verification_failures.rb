class CreateUserVerificationFailures < ActiveRecord::Migration
  def change
    create_table :user_verification_failures do |t|
      t.integer :user_id

      t.timestamps
    end
  end
end
