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

      if Input.trigger?(Input::RIGHT)
        @model.selected_tab += 1
      elsif Input.trigger?(Input::LEFT)
        @model.selected_tab -= 1
      elsif Input.trigger?(Input::B)
        break
      elsif Input.trigger?(Input::DOWN)
        @model.selected_item += 1
      elsif Input.trigger?(Input::UP)
        @model.selected_item -= 1
      elsif Input.trigger?(Input::C)
        echo "A was pressed!"
        @model.selectApparel($Trainer.outfitstate)
      end

      Input.update
      Graphics.update
    end
    @scene.pbEndScene
  end

end
