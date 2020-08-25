require 'Ciudadano.rb'
require 'ProyectoParticipativo.rb'
require 'Menu.rb'
require 'Colectivo.rb'
require 'date'

class Aplicacion
  #################################################
  #Funcion para añadir los colectivos disponibles para apuntarse
  #################################################
  def addColectivos(col, auxArray)
    if col.conjuntoColectivos.empty?
      auxArray.push(col)
    else
      for col2 in col.conjuntoColectivos
        addColectivos(col2, auxArray)
      end
      auxArray.push(col)
    end
  end

  #################################################
  #Funcion que devuelve una lista con los colectivos de los que c es representante
  #################################################
  def listaColectivosIndividuo(c, conjuntoColectivos)

    auxArray = Array.new
    #Bucle para mirar si el usuario tiene algun otro conjunto creado
    for col in conjuntoColectivos
      if col.representante.eql?(c)
        auxArray.push(col)
      end
    end
    auxArray
  end

  #################################################
  #Funcion que permite a un ciudadano apuntarse a un proyecto
  #################################################
  def apuntarseAProyectoCiudadano(c, conjuntoColectivos, conjuntoProyectos)
    auxArray = Array.new

    for pro in conjuntoProyectos
      if pro.buscarIndividuo(c) == 0
        auxArray.push(pro)
      end
    end

    if auxArray.empty? ==false
      puts "Indique que proyecto desea apoyar"

      for i in 1..auxArray.length()
        puts "#{i} - #{auxArray[i-1].titulo}"
      end
      #Control de errores de numeros introducidos
      flagGets = 0
      while flagGets == 0
        numero = gets.to_i
        if numero < 1  or numero > auxArray.length()
          puts "Numero no valido. Intentelo de nuevo"
        else
          flagGets = 1
        end
      end

      auxArray[numero-1].addAfiliado(c)
    else
      puts "No hay proyectos disponibles para usted"
    end
  end

  #################################################
  #Funcion para el menu de la sesion iniciada
  #################################################
  def menuIniciado(c, conjuntoColectivos, conjuntoProyectos)
    #Creacion del nuevo menu para el usuario logeado
    menu = Menu.new("Cambiar contraseña","Crear colectivo","Apuntarse a colectivo", "Darse de baja del colectivo", "Crear proyecto participativo", "Apoyar un proyecto participativo", "Generar informes", "Cerrar Sesion")
    #Seleccion de opcion para el menu de logeado

    while ((eleccion = menu.elegir_opcion) != 8)
      puts "\n"
      #####################################################################################
      # CAMBIO DE CONTRASEÑA
      #####################################################################################
      if eleccion == 1
        puts "Introduzca la nueva contraseña:"
        ps = gets.to_s
        c.pass = ps
        puts "Contraseña modificada correctamente"
        #####################################################################################
        # CREAR COLECTIVOS
        #####################################################################################
      elsif eleccion == 2
        puts "Introduzca el nombre del colectivo:"
        nm = gets.to_s
        aux = Colectivo.new(nm, c)
        #Se comprueba si el conjunto de colectivos global esta vacio o no para saber si ya existe
        if conjuntoColectivos.empty? == false
          flag = 0
          #Bucle para comprobar si ya existe (a partir del nombre)
          for col in conjuntoColectivos
            if col.eql?(aux) == true
              flag = 1
            end
          end
          #Si no existe, se mira si el usuario ya tiene algun otro colectivo creado
          if flag == 0
            auxArray = listaColectivosIndividuo(c, conjuntoColectivos)
            #Si el array no está vacío significa que el usuario ha creado otro colectivo previamente
            if auxArray.empty? == false
              puts "¿Desea incluir este colectivo dentro de alguno de sus otros colectivos? (S/N)"
              sn = gets.to_s.chomp
              #Si introduce S o s, se mostrará la lista de colectivos que tiene creados
              if sn == "S" or sn =="s"
                puts "Indique en cual debe ser incluido"
                flag = 0
                #Bucle para mostrar los colectivos creados
                for i in 1..auxArray.length()
                  puts "#{i} - #{auxArray[i-1].nombre}"
                end
                #Control de errores de numeros introducidos
                flagGets = 0
                while flagGets == 0
                  numero = gets.to_i
                  if numero < 1  or numero > auxArray.length()
                    puts "Numero no valido. Intentelo de nuevo"
                  else
                    flagGets = 1
                  end
                end
                aux.padre = auxArray[i-1]
                auxArray[i-1].addHijo(aux)
                conjuntoColectivos.push(aux)
                #Si introduce cualquier cosa que no sea S o s no se añadira como subconjunto
              else
                conjuntoColectivos.push(aux)
              end

            end

          end
          #Si no tiene ningun otro conjunto creado el usuario, se añade al conjunto global sin hacer nada mas
        else
          conjuntoColectivos.push(aux)
        end

        #####################################################################################
        # APUNTARSE A COLECTIVOS
        #####################################################################################

        #Apuntarse a un colectivo, solo se mostrarán los colectivos disponibles a los que se podrá apuntar
        #es decir, los colectivos en los que directa o inidrectamente no se encuentre ya afiliado

        #Lo que haremos será mirar con un bucle la lista de colectivos y cada vez que encontremos uno sin padre
        #(raiz del arbol de colectivos) y no sea el creador de este, mirar por todos sus hijos a ver si está
        #como afiliado, si no está, se añadirán a la lista de colectivos disponibles para apuntarse
      elsif eleccion == 3
        auxArray = Array.new
        #Bucle para recorrer los colectivos
        for col in conjuntoColectivos
          flag = 0
          #Si es colectivo raiz
          if col.padre == nil
            #Si no es el representante/creador del colectivo
            if col.representante.eql?(c) == false
              #Si el colectivo no tiene subcolectivos
              if col.conjuntoColectivos.empty?
                flag = col.comprobarCiudadano(c)
                #Si no se le ha encontrado en la lista de afiliados
                if flag == 0
                  auxArray.push(col)
                end
                #Si existen subcolectivos
              else
                flag = col.comprobarCiudadano2(c)
                if flag == 0
                  addColectivos(col, auxArray)
                end
              end
            end
          end
        end

        if auxArray.empty? == false
          #Tras incluir en el array los colectivos a los que poder apuntarse, se muestran para que elija uno
          puts "Indique a que colectivo quiere afiliarse"
          #Bucle para mostrar los colectivos creados
          for i in 1..auxArray.length()
            puts "#{i} - #{auxArray[i-1].nombre}"
          end
          #Control de errores de numeros introducidos
          flagGets = 0
          while flagGets == 0
            numero = gets.to_i
            if numero < 1  or numero > auxArray.length()
              puts "Numero no valido. Intentelo de nuevo"
            else
              flagGets = 1
            end
          end

          auxArray[numero-1].addAfiliado(c)
        else
          puts "No hay colectivos disponibles"
        end
        #####################################################################################
        # DARSE DE BAJA DE COLECTIVOS
        #####################################################################################
      elsif eleccion == 4
        auxArray = Array.new
        #Bucle para cmprobar en que colectivos el ciudadano está afiliado
        for col in conjuntoColectivos
          if col.afiliados.empty? == false
            for ciu in col.afiliados
              if ciu.eql?(c)
                auxArray.append(col)
                break
              end
            end
          end
        end

        if auxArray.empty? == false
          puts "Indique de cual desea ser dado de baja"
          flag = 0
          #Bucle para mostrar los colectivos creados
          for i in 1..auxArray.length()
            puts "#{i} - #{auxArray[i-1].nombre}"
          end
          #Control de errores de numeros introducidos
          flagGets = 0
          while flagGets == 0
            numero = gets.to_i
            if numero < 1  or numero > auxArray.length()
              puts "Numero no valido. Intentelo de nuevo"
            else
              flagGets = 1
            end
          end

          auxArray[numero-1].remAfiliado(c)

        else
          puts "Usted no pertence a ningun colectivo"
        end

        #####################################################################################
        # CREAR PROYECTOS
        #####################################################################################
      elsif eleccion == 5
        puts "Introduzca el nombre del proyecto:"
        titulo = gets.to_s
        puts "Introduzca la descripcion del proyecto:"

        descr = gets.to_s
        aux = ProyectoParticipativo.new(titulo, descr, c)
        flag = 0
        #Comprobacion de si existe ya un proyecto con ese nombre
        if conjuntoProyectos.empty? == false

          #Bucle para comprobar si ya existe (a partir del titulo)
          for pro in conjuntoProyectos
            if pro.eql?(aux) == true
              puts "Ese proyecto ya esta creado"
              flag = 1
            end
          end
        end

        #Si no existe un proyecto con ese nombre, se sigue la creacion
        if flag == 0

          auxArray = listaColectivosIndividuo(c, conjuntoColectivos)

          #Si el usuario es representante de colectivos, se le pregnta si quiere crear el proyecto como colectivo
          if auxArray.empty? == false
            puts "¿Desea crearlo como colectivo? (S/N)"
            respuesta = gets.to_s.chomp

            if respuesta == "s" or respuesta == "S"
              puts "Indique como que colectivo desea crearlo"
              flag = 0
              #Bucle para mostrar los colectivos creados
              for i in 1..auxArray.length()
                puts "#{i} - #{auxArray[i-1].nombre}"
              end
              #Control de errores de numeros introducidos
              flagGets = 0
              while flagGets == 0
                numero = gets.to_i
                if numero < 1  or numero > auxArray.length()
                  puts "Numero no valido. Intentelo de nuevo"
                else
                  flagGets = 1
                end
              end

              aux = ProyectoParticipativo.new(titulo, descr, auxArray[numero-1], true)
              auxArray[numero-1].addProyecto(aux)
              conjuntoProyectos.push(aux)
            else
              aux = ProyectoParticipativo.new(titulo, descr, c)
              conjuntoProyectos.push(aux)
            end
          else
            #El usuario no es representante de ningun colectivo
            conjuntoProyectos.push(aux)
          end
        end

        #####################################################################################
        # APUNTARSE A PROYECTOS
        #####################################################################################
      elsif eleccion == 6
        auxArray = listaColectivosIndividuo(c, conjuntoColectivos)
        #Si el usuario es representate de algun colectivo
        if auxArray.empty? == false
          puts "Desea apoyar un proyecto como colectivo?(S/N)"
          respuesta = gets.to_s.chomp
          #Si decide apoyar un proyecto como colectivo
          if respuesta == "s" or respuesta == "S"
            puts "Indique como que colectivo desea apoyar un proyecto"

            for i in 1..auxArray.length()
              puts "#{i} - #{auxArray[i-1].nombre}"
            end
            #Control de errores de numeros introducidos
            flagGets = 0
            while flagGets == 0
              numero = gets.to_i
              if numero < 1  or numero > auxArray.length()
                puts "Numero no valido. Intentelo de nuevo"
              else
                flagGets = 1
              end
            end

            colectivo = auxArray[numero-1]

            #Bucle para buscar los proyectos a los que se puede apuntar un colectivo
            auxArray2 = Array.new
            for pro in conjuntoProyectos
              if pro.buscarColectivo(colectivo) == 0
                auxArray2.push(pro)
              end
            end

            #Si existen proyectos disponibles
            if auxArray2.empty? == false
              puts "Indique que proyecto desea apoyar"

              for i in 1..auxArray2.length()
                puts "#{i} - #{auxArray2[i-1].titulo}"
              end
              #Control de errores de numeros introducidos
              flagGets = 0
              while flagGets == 0
                numero = gets.to_i
                if numero < 1  or numero > auxArray2.length()
                  puts "Numero no valido. Intentelo de nuevo"
                else
                  flagGets = 1
                end
              end

              proyecto = auxArray2[numero-1]
              proyecto.limpiarSucesores(colectivo)
              proyecto.addColectivo(colectivo)
            else
              puts "No hay proyectos disponibles para apuntarse"
            end
          else
            apuntarseAProyectoCiudadano(c, conjuntoColectivos, conjuntoProyectos)
          end
        else
          apuntarseAProyectoCiudadano(c, conjuntoColectivos, conjuntoProyectos)
        end
        #################################################
        #GENERAR INFORMES
        #################################################
      elsif eleccion == 7

        puts "Elija el tipo de informe a producir:"
        puts "1 - Informe de popularidad"
        puts "2 - Informe de afinidad"
        numero = gets.to_i

        #Informe de popularidad
        if numero == 1
          if conjuntoProyectos.empty? == false
            f = File.new("afinidad.txt", "w")
            f.puts "Popularidad de los proyectos actuales (#{DateTime.now})"

            for pro in conjuntoProyectos
              pro.escribirPopularidad(f)
            end

            f.close()
          else
            puts "No hay proyectos suficientes para realizar el informe"
          end
          #Informe de afinidad
        elsif numero == 2
          if conjuntoColectivos.length >= 2
            puts "De que proyectos quieres saber su afinidad?"
            aux = conjuntoColectivos
            #Bucle para mostrar todos los proyectos
            for i in 1..aux.length()
              puts "#{i} - #{aux[i-1].nombre}"
            end
            #Seleccion 1: conjuntoProyectos[seleccion1 -1]
            #Seleccion 2:
            flagGets = 0
            while flagGets == 0
              numero1 = gets.to_i
              numero2 = gets.to_i

              if numero1 < 1  or numero1 > aux.length() or numero2 < 1  or numero2 > aux.length()
                puts "Numero no valido. Intentelo de nuevo"
              else
                colectivo1 = conjuntoColectivos[numero1-1]
                colectivo2 = conjuntoColectivos[numero2-1]

                flagGets = 1
              end
            end

            #col1.comprobarAfinidad(col2)
            #col2.comprobarAfinidad(col1)

            # ^ Recorrer el array de proyectos creados y llamar a pro.buscarColectivo(col2)
            # ^ el numero a devolver será entre el numero del array de proyectos de cada colectivo
            afinidad1 = colectivo1.comprobarAfinidad(colectivo2)
            afinidad2 = colectivo2.comprobarAfinidad(colectivo1)
            afinidad = (afinidad1+afinidad2)/ ((colectivo1.conjuntoProyectos.length)+(colectivo2.conjuntoProyectos.length))
            #Escribir el fiyero
          else
            puts "No hay proyectos suficientes para realizar el informe"
          end
        else
          puts "Opción no válida"
        end

      end
    end
  end

  #################################################
  #Funcion principal del programa
  #################################################

  def main
    conjuntoCiudadanos = Array.new
    conjuntoColectivos = Array.new
    conjuntoProyectos = Array.new
    menu = Menu.new("Registrar ciudadano", "Acceder a la aplicacion", "Salir")
    while ((eleccion = menu.elegir_opcion) != 3)

      if eleccion == 1

        puts "Registrando a un ciudadano"

        puts "Inserte un nombre"
        nombre=gets.to_s

        puts "Inserte un nif"
        nif=gets.to_s

        puts "Inserte una pass"
        pass=gets.to_s

        aux = Ciudadano.new(nombre, nif, pass)
        flag = 0
        if conjuntoCiudadanos.empty? == false
          for c in conjuntoCiudadanos
            if aux.eql?(c) == true
              flag = 1
              puts "El usuario ya existe"
            end
          end
          if flag == 0
            conjuntoCiudadanos.push((Ciudadano.new(nombre, nif, pass)))
          end
        else
          conjuntoCiudadanos.push((Ciudadano.new(nombre, nif, pass)))
        end

      elsif eleccion == 2
        puts "Inserte su nombre o NIF: "
        id = gets.to_s
        puts "Inserte su contraseña: "
        ps = gets.to_s

        flag = 0
        for c in conjuntoCiudadanos
          if id == c.nif or id == c.nombre
            if ps == c.pass
              puts "Sesion iniciada"
              flag = 1
              menuIniciado(c, conjuntoColectivos, conjuntoProyectos)
              menu = Menu.new("Registrar ciudadano", "Acceder a la aplicacion", "Salir")
            end
          end
        end

        if flag == 0
          puts "Datos incorrectos, vuelva a intentarlo"
        end
      else
        puts "Opcion incorrecta. Vuelva a elegir"

      end

      print "\n"

    end
  end
end
