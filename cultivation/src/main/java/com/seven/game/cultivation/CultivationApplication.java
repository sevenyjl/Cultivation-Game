package com.seven.game.cultivation;

import com.seven.game.cultivation.entity.BaseCultivator;
import com.seven.game.cultivation.entity.Place;
import com.seven.game.cultivation.manager.CultivatorManager;
import com.seven.game.cultivation.manager.PlaceManager;
import jakarta.annotation.PostConstruct;
import jakarta.annotation.Resource;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class CultivationApplication {
    @Resource
    private CultivatorManager cultivatorManager;
    @Resource
    private PlaceManager placeManager;

    public static void main(String[] args) {
        SpringApplication.run(CultivationApplication.class, args);
    }

    @PostConstruct
    public void init() {
        // 随机生成10个地点
        for (int i = 0; i < 10; i++) {
            placeManager.addPlace(new Place().randomAssignmentMethod());
        }
        // 随机生成10个修炼者
        for (int i = 0; i < 10; i++) {
            cultivatorManager.addCultivator(new BaseCultivator().randomAssignmentMethod());
        }
    }
}
