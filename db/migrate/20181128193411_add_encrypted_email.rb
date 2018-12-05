class AddEncryptedEmail < ActiveRecord::Migration
  def change
	  add_column :applicants, :encrypted_email, :string
	  add_column :applicants, :salt, :string
  end
end
