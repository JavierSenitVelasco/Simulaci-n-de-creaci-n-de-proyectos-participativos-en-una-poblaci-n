class Colectivo
  def initialize (nombre, representante)
    @nombre=nombre
    @representante=representante
    @conjuntoColectivos = Array.new
    @afiliados = Array.new
    @padre = nil
    @conjuntoProyectos = Array.new
  end

  attr_reader:nombre,:representante, :conjuntoColectivos, :afiliados, :conjuntoProyectos
  attr_accessor:padre

  def eql?(other)
    @nombre == other.nombre
  end

  def to_s
    puts @nombre
  end

  def addHijo(col)
    @conjuntoColectivos.push(col)
  end

  def addAfiliado(af)
    @afiliados.push(af)
  end

  def remAfiliado(af)
    @afiliados.delete(af)
  end

  def addProyecto(af)
    @conjuntoProyectos.push(af)
  end

  def remProyecto(af)
    @conjuntoProyectos.delete(af)
  end

  def calcularAfiliados()
    tamano = 0
    if @conjuntoColectivos.empty?
      if @afiliados.empty? == false
        tamano = @afiliados.length
      end
    else
      for col in @conjuntoColectivos
        tamano += col.calcularAfiliados()
      end

      if @afiliados.empty? == false
        tamano += @afiliados.length
      end

    end
    tamano
  end

  def comprobarCiudadano(c)
    flag = 0
    #Si el colectivo tiene afiliados
    if @afiliados.empty? == false
      #Bucle para mirar si el ciudadano ya está afiliado
      for ciu in @afiliados
        if ciu.eql?(c)
          flag = 1
        end
      end
    end
    flag
  end

  def comprobarCiudadano2(c)
    flag = 0

    #Caso tope, no hay mas hijos
    if @conjuntoColectivos.empty?
      if @afiliados.empty? == false
        for ciu in @afiliados
          if ciu.eql?(c)
            flag = 1
          end
        end
      end
    else
      #Bucle para recorrer todos los subcolectivos
      for col in @conjuntoColectivos
        aux = col.comprobarCiudadano2(c)

        #Si de alguno de los hijos llega un 1, hay que terminar la ejecucion del bucle, pues ya sabemos que se ha
        #encontrado en alguno de los subcolectivos
        if aux == 1
          flag = 1
          break
        end

      end
      #Solo se comprueba en caso de que de todos los hijos haya llegado un 0
      if aux == 0
        if @afiliados.empty? == false

          for ciu in @afiliados
            if ciu.eql?(c)
              flag = 1
            end
          end
        end
      end
    end
    flag
  end

  def comprobarAfinidad(col)
    num = 0
    for proy in @conjuntoProyectos
      if proy.buscarColectivo(col) == 1
        num +=1
      else
        num = num
      end

    end
    num
  end

  def to_s
    puts "Nombre: #{nombre}\n Padre: #{padre}\n Hijos: #{conjuntoColectivos} "
  end

end

