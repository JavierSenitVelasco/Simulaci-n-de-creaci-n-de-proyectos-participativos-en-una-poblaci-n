class Menu

  attr_reader:quit
  def initialize(*menu_args)

    @menu_args=menu_args
    @quit = @menu_args.length

  end

  def elegir_opcion
    #imprimimos el menu
    @menu_args.each.with_index do |item, index|
      puts "#{index+1}. #{item}"
    end
    print "Escoge una opcion: "
    eleccion = gets.to_i

  end

end

