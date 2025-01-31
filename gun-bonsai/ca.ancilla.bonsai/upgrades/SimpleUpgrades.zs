// Simple upgrades that don't need any aux classes and have simple implementations
#namespace TFLV::Upgrade;

class ::BlastShaping : ::BaseUpgrade {
  override double ModifyDamageReceived(Actor pawn, Actor shot, Actor attacker, double damage) {
    if (pawn != attacker) return damage;
    return damage * 0.5 ** level;
  }

  override bool IsSuitableForPlayer(TFLV::PerPlayerStats stats) {
    return true;
  }
}

class ::BouncyShots : ::BaseUpgrade {
  override void OnProjectileCreated(Actor player, Actor shot) {
    shot.bBOUNCEONWALLS = true;
    shot.bBOUNCEONCEILINGS = true;
    shot.bBOUNCEONFLOORS = true;
    shot.bBOUNCEAUTOOFFFLOORONLY = true;
    shot.BounceCount = max(shot.BounceCount, 1 + level);
    shot.BounceFactor = 1.0;
    if (level >= 3) {
      shot.bALLOWBOUNCEONACTORS = true;
      shot.bBOUNCEONACTORS = true;
      shot.bBOUNCEONUNRIPPABLES = true;
    }
  }

  override bool IsSuitableForWeapon(TFLV::WeaponInfo info) {
    return info.IsProjectile() && info.upgrades.Level("::PiercingShots") == 0;
  }
}

class ::FastShots : ::BaseUpgrade {
  override void OnProjectileCreated(Actor player, Actor shot) {
    shot.A_ScaleVelocity(1 + 0.5*level);
  }

  override bool IsSuitableForWeapon(TFLV::WeaponInfo info) {
    return info.IsProjectile();
  }
}

class ::PiercingShots : ::BaseUpgrade {
  override void OnProjectileCreated(Actor player, Actor shot) {
    shot.bRIPPER = true;
  }

  override bool IsSuitableForWeapon(TFLV::WeaponInfo info) {
    return info.IsProjectile()
      && info.upgrades.Level("::PiercingShots") == 0
      && info.upgrades.Level("::FastShots") >= 2
      && info.upgrades.Level("::PiercingShots") < 5
      && info.upgrades.Level("::BouncyShots") == 0
      && info.upgrades.Level("::FragmentationShots") == 0;
  }
}

class ::PlayerDamage : ::BaseUpgrade {
  override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage) {
    // 10% damage bonus per level, but always at least 1 extra point per level.
    double bonus = damage * (self.level * 0.10);
    return damage + (bonus < self.level ? self.level : bonus);
  }

  override bool IsSuitableForPlayer(TFLV::PerPlayerStats stats) {
    return true;
  }
}

class ::ToughAsNails : ::BaseUpgrade {
  override double ModifyDamageReceived(Actor pawn, Actor shot, Actor attacker, double damage) {
    // 10% resistance per level, multiplicative
    double newdamage = damage * (0.90 ** self.level);
    return max(1, min(newdamage, damage - level));
  }

  override bool IsSuitableForPlayer(TFLV::PerPlayerStats stats) {
    return true;
  }
}

class ::WeaponDamage : ::BaseUpgrade {
  override double ModifyDamageDealt(Actor pawn, Actor shot, Actor target, double damage) {
    // 25% damage bonus per level, but always at least 2 extra points per level.
    double bonus = damage * (self.level * 0.25);
    return damage + (bonus < self.level ? self.level*2 : bonus);
  }

  override bool IsSuitableForWeapon(TFLV::WeaponInfo info) {
    return true;
  }
}
