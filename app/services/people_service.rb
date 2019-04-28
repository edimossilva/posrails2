class PeopleService
  def create(create_people_params)
    Pessoa.create create_people_params
  end

  def all
    Pessoa.all
  end
end