classdef DoBotControl
    % DOBOTCONTROL Class to control movement of the manipulator
    
    properties (Constant)
        jointStateSubscriber = rossubscriber('/dobot/state');               % Subscriber to joint states of robot
        jointService = rossvcclient('/dobot/joint_angles');                 % Service to control joint angles of robot
        cartService = rossvcclient('/dobot/cartesian');                     % Service to control Cartesian coordinates of robot
    end

    properties
        jointSubStatus = 0;                                                 % Status of joint state subscriber intialisation
        jointSrvStatus = 0;                                                 % Status of joint state service initialisation
        cartSrvStatus = 0;                                                  % Status of Cartesian service initialisation
    end
    
    methods
        function self = DoBotControl()
            % DOBOTCONTROL Define all functions required in the class
            self.Initialise();
            self.MoveJoints(Base,RearArm,ForeArm);
            self.MoveCart(x,y,z);
        end
    end

    methods (Static)        
        function Initialise()
            % INITIALISE Initialise connection with DoBot through ROS

            % Initialise ROS
            rosinit('138.25.49.44');

            % Check DoBot is initialised
            ready = find(cell2mat(strfind(rosmsg('list'),'dobot')),1);

            if ready ~= 1
                display('ROS messages not available')
            end

            % Subscribe to the joint state topic
            jointStateSubscriber = DoBotControl.jointStateSubscriber;
            DoBotControl.jointSubStatus = 1;
            receive(jointStateSubscriber,2)
            msg = jointStateSubscriber.LatestMessage;
        end

        function MoveJoints(Base,RearArm,ForeArm)
            % MOVEJOINTS Move to an end effector pose using joint states
            % Function accepts joint angles in DEGREES

            % If service is not established, initialise the connection
            if DoBotControl.jointSrvStatus ~= 1
                % Establish service connection
                jointService = DoBotControl.jointService;
    
                % Prepare message
                jointMsg = rosmessage('dobot_ros/SetPosAngRequest');
                % Identify service is established
                DoBotControl.jointSrvStatus = 1;
            end
            
            % Populate message with required joint angles
            jointMsg.RearArmAngle = deg2rad(RearArm);
            jointMsg.ForeArmAngle = deg2rad(ForeArm);
            jointMsg.BaseAngle = deg2rad(Base);

            % Service call to send message
            jointService.call(jointMsg)
            display('Joint movement message sent')
        end

        function MoveCart(x,y,z)
            % MOVECART Move to an end effector pose in Cartesian coordinates
            % Function accepts GLOBAL [x,y,z] point

            % If service is not established, initialise the connection
            if DoBotControl.cartSrvStatus ~= 1
                % Establish service connection
                cartService = DoBotControl.cartService;
    
                % Prepare message
                cartMsg = rosmessage(cartService);

                % Identify service is established
                DoBotControl.cartSrvStatus = 1;
            end

            % Populate message with required coordinates
            cartMsg.Pos.X = x;
            cartMsg.Pos.Y = y;
            cartMsg.Pos.Z = z;

            % Service call to send message
            cartService.call(cartMsg)
            display('Cartesian movement message sent')
        end
    end
end

