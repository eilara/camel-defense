{
    app_args => [
        w     => 640,
        h     => 480,
        title => 'Example Game',
    ],

    worlds => [
        {
            title => 'Tutorial',

            grid_args => [
                marks_args => [
                    spacing    => 24,
                    grid_color => 0x1F1F1FFF,
                    bg_color   => 0x5F5F5FFF,
                ],
                waypoint_list_args => [
                    waypoint_color => 0x9F9F9FFF,
                    path_color     => 0x7F7F7FFF,
                ],
            ],

            wave_manager_args => [
                wave_defs => [
                    {
                        creep_count      => 10,
                        inter_creep_wait => 0.5,
                        creep_args       => [
                            kind => 'normal',
                            v    => 50,
                            hp   => 10,
                        ],
                    },
                    {
                        creep_count      => 7,
                        inter_creep_wait => 0.2,
                        creep_args       => [
                            kind => 'fast',
                            v    => 85,
                            hp   => 10,
                        ],
                    },
                    {
                        creep_count      => 13,
                        inter_creep_wait => 1,
                        creep_args       => [
                            kind => 'slow',
                            v    => 20,
                            hp   => 20,
                        ],
                    },
                ],
            ],

            tower_manager_args => [
                tower_defs => [
                    {
                        type           => 'CamelDefense::Tower::Laser',
                        range          => 110,
                        damage_per_sec => 3,
                        laser_color    => 0x501265FF,
                    },
                    {
                        type            => 'CamelDefense::Tower::Splash',
                        range           => 70,
                        cool_off_period => 1.0,
                        projectile_args => [
                            v      => 300,
                            range  => 30,
                            damage => 1,
                            
                        ],
                    },
                    {
                        type            => 'CamelDefense::Tower::Slow',
                        range           => 50,
                        cool_off_period => 1.0,
                        slow_percent    => 13,
                    },
                ],
            ],
            waypoints  => [
                [0.50, 0.00],
                [0.50, 0.25],
                [0.25, 0.25],
                [0.25, 0.50],
                [0.75, 0.50],
                [0.75, 0.75],
                [0.50, 0.75],
                [0.50, 0.97],
            ],
        },
    ],
}

