package com.seven.game.cultivation.core;

/**
 * 时间流逝能力，每次游戏时间流逝时，会触发该能力
 * 例如：每次时间流逝时，修仙者都会进行动作处理，吸收灵气，恢复生命等
 */
public interface TimePasses {
    /**
     * 时间流逝时触发的能力
     */
    void timePasses();
}
