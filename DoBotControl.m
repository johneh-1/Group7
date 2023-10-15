classdef DoBotControl
    % DOBOTCONTROL Class to control movement of the manipulator
    
    properties (Constant)
        % jointStateSubscriber = rossubscriber('/dobot/state');               % Subscriber to joint states of robot
        % jointService = rossvcclient('/dobot/joint_angles');                 % Service to control joint angles of robot
        % cartService = rossvcclient('/dobot/cartesian');                     % Service to control Cartesian coordinates of robot
    end

    properties
        % jointSubStatus = 0;                                                 % Status of joint state subscriber intialisation
        % jointSrvStatus = 0;                                                 % Status of joint state service initialisation
        % cartSrvStatus = 0;                                                  % Status of Cartesian service initialisation
    end
    
    methods
        function self = DoBotControl()
            % DOBOTCONTROL Define all functions required in the class
            self.MoveCart(x,y,z);
            self.RotateEndEffector();
        end
    end

    methods (Static)        
        function MoveCart(x,y,z)
            % MOVECART Move to an end effector pose in Cartesian coordinates
            % Function accepts [x,y,z] point as target

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

        function [base,rearArm,foreArm,ee] = RotateEndEffector()
            % ROTATEENDEFFECTOR Return joint state for piece orientation
        end
    end
end

