class Ciudadano
  def initialize (nombre, nif, pass)
    @nombre=nombre
    @nif=nif
    @pass=pass
  end
  attr_reader :nombre, :nif
  attr_accessor :pass

  def eql? (other)
    @nombre == other.nombre or @nif == other.nif
  end

  def hash
    @nombre.hash ^ @nif.hash # XOR
  end

  def to_s
    puts "Nombre: #{nombre} NIF: #{nif} PASS: #{pass}"
  end

end

