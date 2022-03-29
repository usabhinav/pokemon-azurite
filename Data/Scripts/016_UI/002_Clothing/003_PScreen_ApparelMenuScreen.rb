class PokemonApparelMenu_Screen

  def initialize(scene, model, outfitstate)
    @scene = scene
    @model = model
    @outfitstate = outfitstate

    @model.attach(@scene)
  end

  def pbStartScreen
    @scene.pbStartScene(@model, @outfitstate)
    loop do
      
      # Input behaviour for every tab.
      if Input.trigger?(Input::RIGHT)
        @model.selected_tab += 1
      elsif Input.trigger?(Input::LEFT)
        @model.selected_tab -= 1
      elsif Input.trigger?(Input::B)
        break
      
      # Input behaviour for specific tabs.
      else
        case @model.selected_tab
          when APPCONST_TAB::SWITCH # Input behaviour for outfit mode toggle tab.
            
            if Input.trigger?(Input::C)
              echoln "A was pressed! Toggling!"
              @model.toggleOutfitMode
            end
            
          else # Input behaviour for generic apparel selection.

            if Input.trigger?(Input::DOWN)
              @model.selected_item += 1
            elsif Input.trigger?(Input::UP)
              @model.selected_item -= 1
            elsif Input.trigger?(Input::C)
              echoln "A was pressed!"
              @model.selectApparel($Trainer.outfitstate)
            end
        end
      end
      
      Input.update
      Graphics.update
      
    end
    @scene.pbEndScene
  end
end
