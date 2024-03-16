
from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import numpy as np


def bbox_transform(ex_rois, gt_rois):
    ex_widths = ex_rois[:, 2] - ex_rois[:, 0] + 1.0
    ex_heights = ex_rois[:, 3] - ex_rois[:, 1] + 1.0
    ex_ctr_x = ex_rois[:, 0] + 0.5 * ex_widths
    ex_ctr_y = ex_rois[:, 1] + 0.5 * ex_heights

    gt_widths = gt_rois[:, 2] - gt_rois[:, 0] + 1.0
    gt_heights = gt_rois[:, 3] - gt_rois[:, 1] + 1.0
    gt_ctr_x = gt_rois[:, 0] + 0.5 * gt_widths
    gt_ctr_y = gt_rois[:, 1] + 0.5 * gt_heights

    targets_dx = (gt_ctr_x - ex_ctr_x) / ex_widths
    targets_dy = (gt_ctr_y - ex_ctr_y) / ex_heights
    targets_dw = np.log(np.maximum(gt_widths, 1.0) / np.maximum(ex_widths, 1.0))
    targets_dh = np.log(np.maximum(gt_heights, 1.0) / np.maximum(ex_heights, 1.0))

    targets = np.vstack(
        (targets_dx, targets_dy, targets_dw, targets_dh)).transpose()
    return targets


def bbox_transform_inv(boxes, deltas):
    if boxes.shape[0] == 0:
        return np.zeros((0, deltas.shape[1]), dtype=deltas.dtype)

    boxes = boxes.astype(deltas.dtype, copy=False)
    widths = boxes[:, 2] - boxes[:, 0] + 1.0
    heights = boxes[:, 3] - boxes[:, 1] + 1.0
    ctr_x = boxes[:, 0] + 0.5 * widths
    ctr_y = boxes[:, 1] + 0.5 * heights
    
    '''
    # 修改下，将 dx, dy, dw, dh 中的空值（NaN）置为1
    dx = np.nan_to_num(deltas[:, 0::4], nan=1)
    dy = np.nan_to_num(deltas[:, 1::4], nan=1)
    dw = np.nan_to_num(deltas[:, 2::4], nan=1)
    dh = np.nan_to_num(deltas[:, 3::4], nan=1)

    '''
    dx = deltas[:, 0::4]
    dy = deltas[:, 1::4]
    dw = deltas[:, 2::4]
    dh = deltas[:, 3::4]
    
    '''
    print("Min value of dw:", np.min(dw))
    print("Max value of dw:", np.max(dw))
    print("Min value of dh:", np.min(dh))
    print("Max value of dh:", np.max(dh))
    '''


    pred_ctr_x = dx * widths[:, np.newaxis] + ctr_x[:, np.newaxis]
    pred_ctr_y = dy * heights[:, np.newaxis] + ctr_y[:, np.newaxis]
    #pred_ctr_x = np.clip(np.clip(dx, a_min=-1e6, a_max=1e6) * widths[:, np.newaxis] + ctr_x[:, np.newaxis], a_min=-1e6, a_max=1e6)
    #pred_ctr_y = np.clip(np.clip(dy, a_min=-1e6, a_max=1e6) * heights[:, np.newaxis] + ctr_y[:, np.newaxis], a_min=-1e6, a_max=1e6)

    pred_w = np.exp(dw) * widths[:, np.newaxis]
    #pred_w = np.clip(np.exp(np.clip(dw, a_min=-1e6, a_max=1e6)) * np.maximum(widths[:, np.newaxis], 1), a_min=-1e6, a_max=1e6)
    pred_h = np.exp(dh) * heights[:, np.newaxis]
    #pred_h = np.exp(np.clip(dh, a_min=-100, a_max=100)) * heights[:, np.newaxis]
    #pred_h = np.clip(np.exp(np.clip(dh, a_min=-1e6, a_max=1e6)) * np.maximum(heights[:, np.newaxis], 1), a_min=-1e6, a_max=1e6)


    pred_boxes = np.zeros(deltas.shape, dtype=deltas.dtype)
    
    # x1
    pred_boxes[:, 0::4] = pred_ctr_x - 0.5 * pred_w
    # y1
    pred_boxes[:, 1::4] = pred_ctr_y - 0.5 * pred_h
    # x2
    pred_boxes[:, 2::4] = pred_ctr_x + 0.5 * pred_w
    # y2
    pred_boxes[:, 3::4] = pred_ctr_y + 0.5 * pred_h
    '''
    pred_boxes[:, 0::4] = np.clip(pred_ctr_x - 0.5 * pred_w, a_min=-1e6, a_max=1e6)
    pred_boxes[:, 1::4] = np.clip(pred_ctr_y - 0.5 * pred_h, a_min=-1e6, a_max=1e6)
    pred_boxes[:, 2::4] = np.clip(pred_ctr_x + 0.5 * pred_w, a_min=-1e6, a_max=1e6)
    pred_boxes[:, 3::4] = np.clip(pred_ctr_y + 0.5 * pred_h, a_min=-1e6, a_max=1e6)
    '''

    return pred_boxes


def clip_boxes(boxes, im_shape):
    """
    Clip boxes to image boundaries.
    """

    # x1 >= 0
    boxes[:, 0::4] = np.maximum(np.minimum(boxes[:, 0::4], im_shape[1] - 1), 0)
    # y1 >= 0
    boxes[:, 1::4] = np.maximum(np.minimum(boxes[:, 1::4], im_shape[0] - 1), 0)
    # x2 < im_shape[1]
    boxes[:, 2::4] = np.maximum(np.minimum(boxes[:, 2::4], im_shape[1] - 1), 0)
    # y2 < im_shape[0]
    boxes[:, 3::4] = np.maximum(np.minimum(boxes[:, 3::4], im_shape[0] - 1), 0)
    return boxes
