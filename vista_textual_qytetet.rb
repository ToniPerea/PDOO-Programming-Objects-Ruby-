#enconding: utf-8
# To change this template file, choose Tools | Templates
# and open the template in the editor.
require_relative "opcion_menu"
require_relative "controlador_qytetet"
require_relative "Qytetet"

module Vistatextualqytetet
  class VistaTextualQytetet
    @@controlador = Controladorqytetet::ControladorQytetet.instance
    @@modelo = ModeloQytetet::Qytetet.instance
    def obtenerNombreJugadores()
      nombres = Array.new
      n = 0
      
      puts "Introduzca numero de jugadores: "
      n=gets.chomp.to_i
      
      if n <= ModeloQytetet::Qytetet.getMaxJugadores and n >= 2
        for i in 0...n
          puts "Escribe el nombre del jugador #{i}: "
          cadena = gets
          nombres << cadena
        end
      end
      nombres
    end
    
    def elegirCasilla(opcionMenu)
      casillas = controlador.obtenerCasillasValidas(opcionMenu)
      casillass = Array.new
      
      if(casillas.isEmpty())
        return -1;
      else
        puts "\nIndique la casilla que desea cambiar: "
        for cas in casillas
          puts "#{cas} "
          casillass.add(Integer.toString(cas))
        end
        return Integer(leerValorCorrecto(casillass))
      end
    end
    
    def leerValorCorrecto(valoresCorrectos)
      orden = ""
      correcto = false
      while(!correcto)
        puts "Que quieres hacer? "
        orden = gets.chomp.to_i
        puts "Entendi" + orden.to_s + "\n"
        
        for valor in valoresCorrectos
          while(!correcto)
            if(orden.equal?(valor))
              correcto = true;
            end
          end
        end
        if(!correcto)
          puts "La orden no es valida, intentalo de nuevo"
        end
      end
      return orden
    end
    
    def elegirOperacion()
      operaciones = @@controlador.obtenerOperacionesJuegoValidas
      ops = Array.new
      print "Ordenes disponibles: "
      for operacion in operaciones
        print "#{operacion} \t #{Controladorqytetet::OpcionMenu::OpcionMenu[operacion]} \n"
        ops << operacion.to_i
      end
      puts ""
      self.leerValorCorrecto(ops).to_i
    end
    
    def self.main
      ui = VistaTextualQytetet.new
      @@controlador.setNombreJugadores(ui.obtenerNombreJugadores)
      
      while(true)
        operacionElegida = ui.elegirOperacion
        necesitaElegirCasilla = @@controlador.necesitaElegirCasilla(operacionElegida)
        if(necesitaElegirCasilla)
          casillaElegida = ui.elegirCasilla(operacionElegida)
        end
        if(!necesitaElegirCasilla||casillaElegida >=0)
          puts @@controlador.realizarOperacion(operacionElegida, casillaElegida)
        end
      end
    end
  end
  VistaTextualQytetet.main
end
