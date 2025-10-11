package com.seven.game.cultivation.utils;

import java.util.Random;

/**
 * 修仙世界工具类
 * 提供修仙者、怪物、世界地点的名称随机生成功能
 */
public class NameUtils {
    
    private static final Random random = new Random();
    
    // 修仙者姓氏
    private static final String[] CULTIVATOR_SURNAMES = {
        "李", "王", "张", "刘", "陈", "杨", "赵", "黄", "周", "吴",
        "徐", "孙", "胡", "朱", "高", "林", "何", "郭", "马", "罗",
        "梁", "宋", "郑", "谢", "韩", "唐", "冯", "于", "董", "萧",
        "程", "曹", "袁", "邓", "许", "傅", "沈", "曾", "彭", "吕",
        "苏", "卢", "蒋", "蔡", "贾", "丁", "魏", "薛", "叶", "阎"
    };
    
    // 修仙者名字前缀
    private static final String[] CULTIVATOR_NAME_PREFIXES = {
        "天", "玄", "云", "风", "雷", "火", "水", "土", "金", "木",
        "星", "月", "日", "辰", "宇", "宙", "乾", "坤", "阴", "阳",
        "青", "白", "赤", "黑", "紫", "蓝", "绿", "黄", "银", "金",
        "龙", "凤", "虎", "麟", "鹤", "鹰", "鹏", "雀", "燕", "蝶"
    };
    
    // 修仙者名字后缀
    private static final String[] CULTIVATOR_NAME_SUFFIXES = {
        "尘", "凡", "空", "虚", "无", "有", "道", "法", "术", "诀",
        "心", "意", "神", "魂", "魄", "灵", "精", "气", "元", "丹",
        "剑", "刀", "枪", "戟", "弓", "箭", "锤", "斧", "鞭", "环",
        "山", "河", "海", "川", "林", "石", "岩", "峰", "谷", "渊"
    };
    
    // 怪物前缀
    private static final String[] MONSTER_PREFIXES = {
        "凶", "恶", "毒", "邪", "妖", "魔", "鬼", "怪", "精", "灵",
        "巨", "大", "小", "老", "幼", "金", "银", "铜", "铁", "石",
        "火", "水", "风", "雷", "冰", "土", "木", "金", "暗", "光",
        "九头", "三眼", "双尾", "独角", "多足", "飞", "爬", "游", "跳", "潜"
    };
    
    // 怪物主体
    private static final String[] MONSTER_BODIES = {
        "蛇", "龙", "虎", "豹", "狼", "熊", "狮", "象", "牛", "马",
        "鹰", "雕", "雀", "燕", "鹤", "鸡", "鸭", "鹅", "鱼", "虾",
        "蝎", "蛛", "蚁", "蜂", "蝶", "蝉", "虫", "蚯", "蚓", "蛆",
        "树", "花", "草", "藤", "蔓", "石", "岩", "土", "沙", "尘",
        "人", "仙", "佛", "神", "鬼", "魂", "魄", "尸", "骨", "血"
    };
    
    // 怪物后缀
    private static final String[] MONSTER_SUFFIXES = {
        "王", "皇", "帝", "尊", "圣", "神", "魔", "鬼", "怪", "精",
        "妖", "兽", "虫", "鸟", "鱼", "树", "花", "草", "石", "土",
        "之魂", "之灵", "之魄", "之影", "之形", "之体", "之心", "之眼", "之手", "之足",
        "长老", "首领", "头目", "将军", "元帅", "大王", "皇帝", "尊者", "圣人", "神仙"
    };
    
    // 世界地点前缀
    private static final String[] LOCATION_PREFIXES = {
        "天", "地", "玄", "黄", "宇", "宙", "洪", "荒", "日", "月",
        "星", "辰", "金", "木", "水", "火", "土", "风", "雷", "电",
        "青", "白", "赤", "黑", "紫", "蓝", "东", "西", "南", "北",
        "上", "下", "左", "右", "前", "后", "内", "外", "中", "央"
    };
    
    // 世界地点主体
    private static final String[] LOCATION_BODIES = {
        "山", "河", "海", "川", "林", "原", "谷", "峰", "岭", "丘",
        "湖", "江", "河", "溪", "泉", "瀑", "潭", "池", "井", "洞",
        "城", "镇", "村", "庄", "寨", "堡", "宫", "殿", "阁", "楼",
        "亭", "台", "塔", "庙", "寺", "观", "庵", "堂", "院", "府"
    };
    
    // 世界地点后缀
    private static final String[] LOCATION_SUFFIXES = {
        "之巅", "之渊", "之源", "之尽", "之间", "之外", "之内", "之上", "之下", "之中",
        "仙境", "魔域", "鬼界", "妖境", "神域", "佛国", "灵地", "宝地", "福地", "洞天",
        "大阵", "结界", "领域", "世界", "空间", "时空", "轮回", "因果", "命运", "天道"
    };
    
    // 地点描述 - 环境特征
    private static final String[] LOCATION_ENVIRONMENT = {
        "云雾缭绕", "灵气充沛", "仙气弥漫", "魔气森森", "鬼气阴森", "妖气冲天", "神光普照", "佛光万丈",
        "灵气稀薄", "灵气浓郁", "灵气狂暴", "灵气温和", "灵气纯净", "灵气污浊", "灵气枯竭", "灵气复苏",
        "山清水秀", "鸟语花香", "风景如画", "景色宜人", "荒凉贫瘠", "寸草不生", "生机勃勃", "死气沉沉",
        "四季如春", "严寒酷暑", "春暖花开", "秋高气爽", "夏日炎炎", "冬雪皑皑", "风雨交加", "雷电交加"
    };
    
    // 地点描述 - 建筑特征
    private static final String[] LOCATION_ARCHITECTURE = {
        "宫殿巍峨", "楼阁耸立", "亭台楼阁", "雕梁画栋", "金碧辉煌", "古朴典雅", "气势恢宏", "雄伟壮观",
        "破败不堪", "残垣断壁", "荒废已久", "年久失修", "崭新如初", "精心维护", "神秘莫测", "诡异莫测",
        "阵法环绕", "结界保护", "禁制重重", "机关密布", "陷阱遍地", "安全无忧", "戒备森严", "自由开放"
    };
    
    // 地点描述 - 资源特征
    private static final String[] LOCATION_RESOURCES = {
        "灵药遍地", "灵石丰富", "灵矿众多", "灵泉涌流", "灵脉纵横", "灵草茂盛", "灵果累累", "灵兽出没",
        "资源匮乏", "资源丰富", "资源稀有", "资源普通", "资源珍贵", "资源常见", "资源枯竭", "资源再生",
        "天材地宝", "奇珍异宝", "法宝众多", "法器遍地", "丹药充足", "符箓丰富", "阵法材料", "炼器材料"
    };
    
    // 地点描述 - 危险程度
    private static final String[] LOCATION_DANGER = {
        "极度危险", "非常危险", "比较危险", "相对安全", "十分安全", "绝对安全", "危机四伏", "险象环生",
        "妖魔横行", "鬼怪出没", "妖兽遍地", "魔物众多", "邪修聚集", "正道守护", "中立区域", "和平地带"
    };
    
    // 地点描述 - 历史传说
    private static final String[] LOCATION_HISTORY = {
        "上古遗迹", "远古战场", "神话传说", "仙人洞府", "魔王巢穴", "妖王领地", "鬼王领域", "神王居所",
        "历史悠久的", "新近建立的", "传说中的", "真实存在的", "神秘消失的", "重新发现的", "从未探索的", "人迹罕至的"
    };
    
    /**
     * 生成随机修仙者名称
     * @return 修仙者名称
     */
    public static String generateCultivatorName() {
        String surname = CULTIVATOR_SURNAMES[random.nextInt(CULTIVATOR_SURNAMES.length)];
        String prefix = CULTIVATOR_NAME_PREFIXES[random.nextInt(CULTIVATOR_NAME_PREFIXES.length)];
        String suffix = CULTIVATOR_NAME_SUFFIXES[random.nextInt(CULTIVATOR_NAME_SUFFIXES.length)];
        
        // 随机决定是单字名还是双字名
        if (random.nextBoolean()) {
            return surname + prefix;
        } else {
            return surname + prefix + suffix;
        }
    }
    
    /**
     * 生成随机怪物名称
     * @return 怪物名称
     */
    public static String generateMonsterName() {
        String prefix = MONSTER_PREFIXES[random.nextInt(MONSTER_PREFIXES.length)];
        String body = MONSTER_BODIES[random.nextInt(MONSTER_BODIES.length)];
        String suffix = MONSTER_SUFFIXES[random.nextInt(MONSTER_SUFFIXES.length)];
        
        // 随机决定是否包含后缀
        if (random.nextBoolean()) {
            return prefix + body + suffix;
        } else {
            return prefix + body;
        }
    }
    
    /**
     * 生成随机世界地点名称
     * @return 世界地点名称
     */
    public static String generateLocationName() {
        String prefix = LOCATION_PREFIXES[random.nextInt(LOCATION_PREFIXES.length)];
        String body = LOCATION_BODIES[random.nextInt(LOCATION_BODIES.length)];
        String suffix = LOCATION_SUFFIXES[random.nextInt(LOCATION_SUFFIXES.length)];
        
        // 随机决定是否包含后缀
        if (random.nextBoolean()) {
            return prefix + body + suffix;
        } else {
            return prefix + body;
        }
    }
    
    /**
     * 批量生成修仙者名称
     * @param count 生成数量
     * @return 修仙者名称数组
     */
    public static String[] generateCultivatorNames(int count) {
        String[] names = new String[count];
        for (int i = 0; i < count; i++) {
            names[i] = generateCultivatorName();
        }
        return names;
    }
    
    /**
     * 批量生成怪物名称
     * @param count 生成数量
     * @return 怪物名称数组
     */
    public static String[] generateMonsterNames(int count) {
        String[] names = new String[count];
        for (int i = 0; i < count; i++) {
            names[i] = generateMonsterName();
        }
        return names;
    }
    
    /**
     * 批量生成世界地点名称
     * @param count 生成数量
     * @return 世界地点名称数组
     */
    public static String[] generateLocationNames(int count) {
        String[] names = new String[count];
        for (int i = 0; i < count; i++) {
            names[i] = generateLocationName();
        }
        return names;
    }
    
    /**
     * 生成随机地点描述
     * @return 地点描述字符串
     */
    public static String generateLocationDescription() {
        // 随机选择2-4个描述特征组合
        int featureCount = 2 + random.nextInt(3); // 2-4个特征
        StringBuilder description = new StringBuilder();
        
        // 确保不重复选择相同的特征类型
        boolean[] usedTypes = new boolean[5]; // 5种特征类型
        
        for (int i = 0; i < featureCount; i++) {
            int type;
            do {
                type = random.nextInt(5); // 0-4分别对应环境、建筑、资源、危险、历史
            } while (usedTypes[type]);
            
            usedTypes[type] = true;
            
            String feature = "";
            switch (type) {
                case 0:
                    feature = LOCATION_ENVIRONMENT[random.nextInt(LOCATION_ENVIRONMENT.length)];
                    break;
                case 1:
                    feature = LOCATION_ARCHITECTURE[random.nextInt(LOCATION_ARCHITECTURE.length)];
                    break;
                case 2:
                    feature = LOCATION_RESOURCES[random.nextInt(LOCATION_RESOURCES.length)];
                    break;
                case 3:
                    feature = LOCATION_DANGER[random.nextInt(LOCATION_DANGER.length)];
                    break;
                case 4:
                    feature = LOCATION_HISTORY[random.nextInt(LOCATION_HISTORY.length)];
                    break;
            }
            
            if (description.length() > 0) {
                description.append("，");
            }
            description.append(feature);
        }
        
        return description.toString();
    }
    
    /**
     * 根据地点名称生成更具体的描述
     * @param locationName 地点名称
     * @return 具体的地点描述
     */
    public static String generateLocationDescription(String locationName) {
        String baseDescription = generateLocationDescription();
        
        // 根据地点名称的特征添加更具体的描述
        if (locationName.contains("山") || locationName.contains("峰") || locationName.contains("岭")) {
            baseDescription += "，山势险峻";
        } else if (locationName.contains("河") || locationName.contains("江") || locationName.contains("海")) {
            baseDescription += "，水波荡漾";
        } else if (locationName.contains("林") || locationName.contains("原")) {
            baseDescription += "，植被茂密";
        } else if (locationName.contains("城") || locationName.contains("镇") || locationName.contains("村")) {
            baseDescription += "，人烟稠密";
        } else if (locationName.contains("宫") || locationName.contains("殿") || locationName.contains("阁")) {
            baseDescription += "，建筑精美";
        }
        
        return baseDescription;
    }
    
    /**
     * 批量生成地点描述
     * @param count 生成数量
     * @return 地点描述数组
     */
    public static String[] generateLocationDescriptions(int count) {
        String[] descriptions = new String[count];
        for (int i = 0; i < count; i++) {
            descriptions[i] = generateLocationDescription();
        }
        return descriptions;
    }
    
    /**
     * 批量生成带名称的地点描述
     * @param locationNames 地点名称数组
     * @return 对应的地点描述数组
     */
    public static String[] generateLocationDescriptions(String[] locationNames) {
        String[] descriptions = new String[locationNames.length];
        for (int i = 0; i < locationNames.length; i++) {
            descriptions[i] = generateLocationDescription(locationNames[i]);
        }
        return descriptions;
    }
}