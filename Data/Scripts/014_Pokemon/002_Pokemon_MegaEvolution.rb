class Pokemon
  #=============================================================================
  # Mega Evolution
  # NOTE: These are treated as form changes in Essentials.
  #=============================================================================
  def getMegaForm
    ret = 0
    GameData::Species.each do |data|
      next if data.species != @species || data.unmega_form != form_simple
      if data.mega_stone && hasItem?(data.mega_stone) && !Settings::CRYSTALLIZATION_ITEMS.include?(data.mega_stone)
        ret = data.form
        break
      elsif data.mega_move && hasMove?(data.mega_move)
        ret = data.form
        break
      end
    end
    return ret   # form number, or 0 if no accessible Mega form
  end

  def getUnmegaForm
    return (mega?) ? species_data.unmega_form : -1
  end

  def hasMegaForm?
    megaForm = self.getMegaForm
    return megaForm > 0 && megaForm != form_simple
  end

  def mega?
    return ((species_data.mega_stone && !Settings::CRYSTALLIZATION_ITEMS.include?(species_data.mega_stone)) || species_data.mega_move) ? true : false
  end

  def makeMega
    megaForm = self.getMegaForm
    self.form = megaForm if megaForm > 0
  end

  def makeUnmega
    old_hp = @hp
    unmegaForm = self.getUnmegaForm
    self.form = unmegaForm if unmegaForm >= 0
    # For now, preventing HP recovery even if the base form has a higher base HP stat
    @hp = 0 if old_hp == 0
  end

  def megaName
    formName = species_data.form_name
    return (formName && !formName.empty?) ? formName : _INTL("Mega {1}", species_data.name)
  end

  def megaMessage   # 0=default message, 1=Rayquaza message
    megaForm = self.getMegaForm
    message_number = GameData::Species.get_species_form(@species, megaForm)&.mega_message
    return message_number || 0
  end

  #=============================================================================
  # Crystallization
  # NOTE: These are treated as form changes in Essentials.
  #=============================================================================
  def getCrystalForm
    ret = 0
    GameData::Species.each do |data|
      next if data.species != @species || data.unmega_form != form_simple
      if data.mega_stone && hasItem?(data.mega_stone) && Settings::CRYSTALLIZATION_ITEMS.include?(data.mega_stone)
        ret = data.form
        break
      end
    end
    return ret   # form number, or 0 if no accessible Crystal form
  end

  def getCrystalFormWithoutItemCheck
    ret = 0
    GameData::Species.each do |data|
      next if data.species != @species || data.unmega_form != form_simple
      if data.mega_stone && Settings::CRYSTALLIZATION_ITEMS.include?(data.mega_stone)
        ret = data.form
        break
      end
    end
    return ret   # form number, or 0 if no accessible Crystal form
  end

  def getUncrystalForm
    return (crystal?) ? species_data.unmega_form : -1
  end

  def hasCrystalForm?
    crystalForm = self.getCrystalForm
    return crystalForm > 0 && crystalForm != form_simple
  end

  def hasCrystalFormWithoutItemCheck?
    crystalForm = self.getCrystalFormWithoutItemCheck
    # If mega, crystal check needs to be against Pokemon of base species, not against the mega form
    if self.mega?
      dup_poke = Marshal.load(Marshal.dump(self))
      dup_poke.makeUnmega
      crystalForm = dup_poke.getCrystalFormWithoutItemCheck
    end
    return crystalForm > 0 && crystalForm != form_simple
  end

  def crystal?
    return (species_data.mega_stone && Settings::CRYSTALLIZATION_ITEMS.include?(species_data.mega_stone)) ? true : false
  end

  def makeCrystal
    crystalForm = self.getCrystalForm
    self.form = crystalForm if crystalForm > 0
  end

  def makeCrystalWithoutItemCheck
    if hasItem?(:EQUALIZERC)
      makeCrystalEqualizer
      return
    end
    crystalForm = self.getCrystalFormWithoutItemCheck
    # If mega, crystal check needs to be against Pokemon of base species, not against the mega form
    if self.mega?
      dup_poke = Marshal.load(Marshal.dump(self))
      dup_poke.makeUnmega
      crystalForm = dup_poke.getCrystalFormWithoutItemCheck
    end
    self.form = crystalForm if crystalForm > 0
  end

  def makeUncrystal
    old_hp = @hp
    uncrystalForm = self.getUncrystalForm
    self.form = uncrystalForm if uncrystalForm >= 0
    # For now, preventing HP recovery even if the base form has a higher base HP stat
    @hp = 0 if old_hp == 0
  end

  def crystalName
    formName = species_data.form_name
    return (formName && !formName.empty?) ? formName : _INTL("Crystal {1}", species_data.name)
  end

  #=============================================================================
  # Equalizers
  # NOTE: These are NOT treated as form changes.
  #=============================================================================

  def megaEqualizer?
    return @equalizer == :EQUALIZERM
  end

  def makeMegaEqualizer
    @equalizer = :EQUALIZERM
  end

  def crystalEqualizer?
    return @equalizer == :EQUALIZERC
  end

  def makeCrystalEqualizer
    @equalizer = :EQUALIZERC
  end

  def makeUnEqualizer
    @equalizer = nil
  end

  def anyEqualizer?
    return !@equalizer.nil?
  end

  #=============================================================================
  # Primal Reversion
  # NOTE: These are treated as form changes in Essentials.
  #=============================================================================
  def hasPrimalForm?
    v = MultipleForms.call("getPrimalForm", self)
    return !v.nil?
  end

  def primal?
    v = MultipleForms.call("getPrimalForm", self)
    return !v.nil? && v == @form
  end

  def makePrimal
    v = MultipleForms.call("getPrimalForm", self)
    self.form = v if !v.nil?
  end

  def makeUnprimal
    old_hp = @hp
    v = MultipleForms.call("getUnprimalForm", self)
    if !v.nil?
      self.form = v
    elsif primal?
      self.form = 0
    end
    # For now, preventing HP recovery even if the base form has a higher base HP stat
    @hp = 0 if old_hp == 0
  end
end
