class PessoaService
  def create(create_pessoa_params)
    Pessoa.create create_pessoa_params
  end

  def all
    Pessoa.all
  end
end
