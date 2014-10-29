require 'rails_helper'

describe ExerciseTask do

  describe 'association' do

    it { should belong_to(:reviewer).class_name(User) }
    it { should have_many(:solutions) }
    it { should have_attached_file(:sample_solution) }

  end

  describe 'validations' do

    it { should validate_presence_of(:reviewer) }
    it { should validate_attachment_content_type(:sample_solution).allowing('application/zip') }

  end

end