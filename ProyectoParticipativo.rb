require 'securerandom'
require 'date'

class ProyectoParticipativo
  def initialize (titulo, descripcion,proponente, propuestoPorColectivo = false)
    @titulo=titulo
    @descripcion=descripcion
    @proponente = proponente
    @id = SecureRandom.uuid
    @fecha = DateTime.now
    @propuestoPorColectivo = propuestoPorColectivo
    @afiliados = Array.new
    @colectivosAfiliados = Array.new

  end

  attr_reader:titulo,:descripcion, :proponente, :id, :fecha

  def addColectivo(col)
    @colectivosAfiliados.push(col)
  end

  def addAfiliado(af)
    @afiliados.push(af)
  end

  def eql?(other)
    @titulo == other.titulo
  end

  def to_s
    puts "Codigo del proyecto  #{titulo}: #{id}"
    puts "fecha de creacion: #{fecha}"

  end

  #Funcion que busca si un ciudadano es afiliado ya de un proyecto
  def buscarIndividuo(c)
    flag = 0
    if @propuestoPorColectivo == false
      if @proponente.eql?(c)
        flag = 1
      end
      if (DateTime.now - @fecha).to_i >= 60
        flag = 1
      end
    end

    if flag == 0
      #Miramos si el ciudadano está en la lista de afiliados del proyecto
      if @afiliados.empty? == false
        for ciu in @afiliados
          if ciu.eql?(c)
            flag = 1
            break
          end
        end
      end
      #Si no lo está, se mirá si está en algún colectivo afiliado (directa o indirectamente)
      if flag==0
        if @colectivosAfiliados.empty? == false
          for col in @colectivosAfiliados
            if col.conjuntoColectivos.empty? == false
              flag = col.comprobarCiudadano(c)
            else
              flag = col.comprobarCiudadano2(c)
            end
            if flag == 1
              break
            end
          end
        end
      end
    end
    flag
  end

  #Funcion para saber si un colectivo o alguno de sus padres está ya en el proyecto
  def buscarColectivo(col)
    flag = 0

    if @propuestoPorColectivo == true
      if @proponente.eql?(col)
        flag = 1
      end
      if (DateTime.now - @fecha).to_i >= 60
        flag = 1
      end
    end

    if flag == 0
      if @colectivosAfiliados.empty? == false

        if col.padre == nil
          for colectivo in @colectivosAfiliados
            if col.eql?(colectivo)
              flag = 1
              break
            end
          end

        else

          flag = buscarColectivo(col.padre)

          if flag == 0
            for colectivo in @colectivosAfiliados
              if col.eql?(colectivo)
                flag = 1
                break
              end
            end
          end

        end
      end
    end

    flag
  end

  #A la hora de apoyar un proyecto como un colectivo hay que quitar los afiliados de subcolectivos de este
  #1º ->bucle recorriendo el arbol de subcolectivos y por cada subcolectivo mirar si alguien apoya este proyect
  #     si se encuentra alguien, se elimina del array de @afiliados
  #     y cuando estamos en un colectivo hoja, mirar si este está como afiliado y borrarlo tambien
  #2º ->tras recorres todo meter el colectivo inicial en el array de @colectivosAfiliados
  def limpiarSucesores(col)

    if col.conjuntoColectivos.empty?
      if col.afiliados.empty? == false
        #Bucle que recorre los afiliados a un colectivo
        for c in col.afiliados
          if @afiliados.empty? == false
            #Bucle que recorre los afiliados a un proyecto
            for ciu in @afiliados
              if ciu.eql?(c)
                @afiliados.delete(c)
                break
              end
            end
          end
        end
      end

      for colec in @colectivosAfiliados
        if colec.eql?(col)
          @colectivosAfiliados.delete(col)
        end
      end
    else
      for colect in col.conjuntoColectivos
        limpiarSucesores(colect)
      end

      if col.afiliados.empty? == false
        #Bucle que recorre los afiliados a un colectivo
        for c in col.afiliados
          if @afiliados.empty? == false
            #Bucle que recorre los afiliados a un proyecto
            for ciu in @afiliados
              if ciu.eql?(c)
                @afiliados.delete(c)
                break
              end
            end
          end
        end
      end

      for colec in @colectivosAfiliados
        if colec.eql?(col)
          @colectivosAfiliados.delete(col)
        end
      end

    end

  end

  #Funcion para calcular y escribir la popularidad en un fichero

  def escribirPopularidad(f)

    #Apoyo ciudadano
    apoyo = @afiliados.length
    if @colectivosAfiliados.empty? == false
      for col in @colectivosAfiliados
        apoyo += col.calcularAfiliados()
      end
    end
    
    f.puts "#{titulo}: #{apoyo}"
    
  end

end
