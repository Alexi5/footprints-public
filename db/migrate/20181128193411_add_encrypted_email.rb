class AddEncryptedEmail < ActiveRecord::Migration
  def change
	  add_column :applicants, :encrypted_email, :string
  end
end
