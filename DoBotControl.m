classdef DoBotControl
    % DOBOTCONTROL Class to control movement of the DoBot Magician
    % Functions enable movement control using either joint states or
    % Cartesian coordinates
    
    methods
        function self = DoBotControl()
            % DOBOTCONTROL Define all functions required in the class
            self.GetJointState();
            self.GetCart();
            self.MoveCart(x,y,z);
            self.CalcEEReqRot(startPos,startJS,endPos,rotTarget);
            self.RotateEndEffector(base,rearArm,foreArm,eeT);
        end
    end

    methods (Static)        
        function [base,rearArm,foreArm,ee] = GetJointState()
            % GETJOINTSTATE Return current joint state of DoBot

            % Initialise subscriber to joint states
            jointStateSubscriber = rossubscriber('/dobot_magician/joint_states');
            pause(2);
            currentJointState = jointStateSubscriber.LatestMessage.Position;

            % Store joint states
            base = currentJointState(1);
            rearArm = currentJointState(2);
            foreArm = currentJointState(3);
            ee = currentJointState(4);

            % Print to terminal
            fprintf('Current joint states are [%d,%d,%d,%d]\n',base,rearArm,foreArm,ee);
        end
        
        function [x,y,z] = GetCart()
            % GETCART Return current Cartesian coordinates of end effector

            % Initialise subscriber to end effector pose
            endEffectorPose = rossubscriber('/dobot_magician/end_effector_poses');
            pause(2);
            currentEndEffectorPoseMsg = endEffectorPose.LatestMessage;

            % Store position of the end effector
            x = currentEndEffectorPoseMsg.Pose.Position.X;
            y = currentEndEffectorPoseMsg.Pose.Position.Y;
            z = currentEndEffectorPoseMsg.Pose.Position.Z;

            % Store orientation of the end effector
            % currentEndEffectorQuat = [currentEndEffectorPoseMsg.Pose.Orientation.W,
            %                           currentEndEffectorPoseMsg.Pose.Orientation.X,
            %                           currentEndEffectorPoseMsg.Pose.Orientation.Y,
            %                           currentEndEffectorPoseMsg.Pose.Orientation.Z]
            % Convert from quaternion to euler
            % [roll,pitch,yaw] = quat2eul(currentEndEffectorQuat);
        end
        
        function MoveCart(x,y,z,R,P,Y)
            % MOVECART Move to an end effector pose in Cartesian coordinates
            % Function accepts [x,y,z] point as target with [R,P,Y]
            % rotation.
            % Parameters:
                % [IN] x = x-coordinate in DoBot's frame
                % [IN] y = y-coordinate in DoBot's frame
                % [IN] z = z-coordinate in DoBot's frame
                % [IN] R = roll value in DoBot's frame
                % [IN] P = pitch value in DoBot's frame
                % [IN] Y = yaw value in DoBot's frame

            % Define target position and rotation from input parameters
            endEffectorPosition = [x,y,z];
            endEffectorRotation = [R,P,Y];
            
            % Initialise publisher to target pose
            [targetEndEffectorPub,targetEndEffectorMsg] = rospublisher('/dobot_magician/target_end_effector_pose');
            
            % Populate position message
            targetEndEffectorMsg.Position.X = endEffectorPosition(1);
            targetEndEffectorMsg.Position.Y = endEffectorPosition(2);
            targetEndEffectorMsg.Position.Z = endEffectorPosition(3);
            
            % Populate rotation message
                % @NOTE: Convert R,P,Y to quaternion
            qua = eul2quat(endEffectorRotation);
            targetEndEffectorMsg.Orientation.W = qua(1);
            targetEndEffectorMsg.Orientation.X = qua(2);
            targetEndEffectorMsg.Orientation.Y = qua(3);
            targetEndEffectorMsg.Orientation.Z = qua(4);
            
            % Send the position and rotation message via the publisher
            send(targetEndEffectorPub,targetEndEffectorMsg)
            pause(2);
            fprintf('Moving to [%d,%d,%d]\n',x,y,z);
        end

        function eeT = CalcEEReqRot(startPos,startJS,endPos,rotTarget)
            % CALCEEREQPOSE Calculate required final end effector pose
            % Based on the total rotation required and the value of
            % rotation achieved by the base, with consideration of initial
            % joint state

            % Calculate radius of startPos
            startRad = sqrt(startPos(1)^2 + startPos(2)^2);

            % Calculate radius of endPos
            endRad = sqrt(endPos(1)^2+endPos(2)^2);

            % Calculate distance between startPos and endPos
            deltaX = endPos(1) - startPos(1);
            deltaY = endPos(2) - startPos(2);
            deltaSE = sqrt(deltaX^2 + deltaY^2);

            % Calculate angle inscribed by the base, using cosine rule
            numerator = startRad^2 + endRad^2 - deltaSE^2;
            denominator = 2 * startRad * endRad;
            rotBase = acos(numerator/denominator);

            % Calculate target end effector rotation
            % EE rotation = final orientation - base rotation - initial EE rotation
            eeT = rotTarget - rotBase - startJS(4);
        end

        function RotateEndEffector(base,rearArm,foreArm,eeT)
            % ROTATEENDEFFECTOR Return joint state for piece orientation

            % Define the target joint state
            jointTarget = [base,rearArm,foreArm,eeT];

            % Initialise the target joint state publisher
            [targetJointTrajPub,targetJointTrajMsg] = rospublisher('/dobot_magician/target_joint_states');
            trajectoryPoint = rosmessage("trajectory_msgs/JointTrajectoryPoint");
            trajectoryPoint.Positions = jointTarget;
            targetJointTrajMsg.Points = trajectoryPoint;
            
            % Send the target joint state via the publisher
            send(targetJointTrajPub,targetJointTrajMsg);
            pause(2);
            fprintf('Rotating end effector to %d\n',eeT);
        end
    end
end

