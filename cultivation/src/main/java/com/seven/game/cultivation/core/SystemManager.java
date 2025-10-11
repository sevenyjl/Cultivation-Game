package com.seven.game.cultivation.core;

import com.seven.game.cultivation.ai.AiManager;
import com.seven.game.cultivation.manager.CultivatorManager;
import com.seven.game.cultivation.manager.PlaceManager;
import jakarta.annotation.Resource;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * 系统管理器
 * 控制游戏时间流逝
 * 读取 AIManager 然后，进行动作处理
 */
@Component
@Slf4j
public class SystemManager {
    @Resource
    private AiManager aiManager;
    @Resource
    private PlaceManager placeManager;
    @Resource
    private CultivatorManager cultivatorManager;


    @Scheduled(fixedRate = 1000)
    public void timePasses() {
        log.info("游戏时间流逝了1秒");
        // 时间流逝时，触发所有地点的时间流逝能力
        placeManager.timePasses();
        aiManager.timePasses();
        // 打印所有修炼者的状态
        placeManager.getAllPlaces().forEach(System.out::println);
    }
}
