class PersonService
  def create(create_person_params)
    Person.create create_person_params
  end

  def all
    Person.all
  end
end